#!/usr/bin/env ruby

require 'getoptlong'
require 'aws-sdk-secretsmanager'

opts = GetoptLong.new(
  [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
  [ '--output', '-o', GetoptLong::OPTIONAL_ARGUMENT ],
)

output = "dotenv"

opts.each do |opt, arg|
  case opt
  when '--help'
    puts <<-EOF
    #{$0} [OPTION] SECRET_NAME

    -h, --help:
       show help

    --output [format]:
       Output following the defined format.
       Options are:
         dotenv - dotenv style [default]
         export - shell export style
         stdout - secret plain value style

    SECRET_NAME: Secret name define on aws secrets manager
    EOF
    exit 0
  when '--output'
    formats = ["dotenv", "export", "stdout"]
    output  = arg

    unless formats.include?(arg)
      puts "#{output} format is not recognizable. Valid formats are: #{formats.join(", ")}"
      exit 1
    end
  end
end

client = Aws::SecretsManager::Client.new

if secret_id = (ARGV.first || ENV["ENV_SECRET_NAME"])
  begin
    secret_values = client.get_secret_value(secret_id: secret_id).secret_string
    if output == "stdout"
      puts secret_values
    else
      suffix = {
        "export" => "export "
      }.fetch(output, "")

      JSON[secret_values].each do |(key, value)|
        puts %Q{#{suffix}#{key}=$'#{value}'}
      end
    end
  rescue Aws::SecretsManager::Errors::AccessDeniedException
    puts "permission denied to: `#{secret_id}`"
    exit 1
  rescue Aws::SecretsManager::Errors::ResourceNotFoundException
    puts "resource not found: `#{secret_id}`"
    exit 1
  end
else
  puts "Usage: #{$0} SECRET_NAME"
  exit 1
end
