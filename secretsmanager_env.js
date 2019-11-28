#!/usr/bin/env node
const aws            = require('aws-sdk');
const secretsmanager = new aws.SecretsManager();

var path = require('path');
var programName = path.basename(process.argv[1]);

const banner = () => {
  const message = `
  Usage: ${programName} [OPTIONS] SECRET_NAME

  -h, --help:
   show help

  --output [format]:
    Output following the defined format.
    Options are:
      dotenv - dotenv style [default]
      export - shell export style
      stdout - secret plain value style

    SECRET_NAME: Secret name define on aws secrets manager
  `;

  console.log(message);
}

const argv = require('minimist')(process.argv.slice(2), {
  'string' : [
    'output',
  ],
  'alias' : {
    'help'    : 'h',
  }
});

if (argv.help) {
  banner();
  process.exit(0);
}

const secretName = (argv._[0] || process.env.ENV_SECRET_NAME)

if (!secretName) {
  console.error(`Usage: ${programName} [OPTIONS] SECRET_NAME`);
  process.exit(1);
}

const output = argv.output

if (output) {
  const formats = ["dotenv", "export", "stdout"]

  if (!formats.includes(output)) {
    console.error(`${output} format is not recognizable. Valid formats are: ${formats.join(", ")}`)
    process.exit(1)
  }
}

const params = {
  SecretId: secretName
}

secretsmanager.getSecretValue(params, function(err, data) {
   if (err) console.log(err, err.stack); // an error occurred

  const secretValues = data.SecretString;

  if(output == 'stdout') {
    console.log(secretValues);
    process.exit(0);
  } else {
    let suffix = "";

    if (output == "export") suffix = "export ";

    const values = JSON.parse(secretValues)
    Object.keys(values).forEach(function (key) {
      console.log(`${suffix}${key}=$'${values[key]}'`);
    });
  }
});
