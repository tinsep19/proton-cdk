## Add any function here that is needed in more than one parts of your
## application, or that you otherwise wish to extract from the main function
## scripts.
##
## Note that code here should be wrapped inside bash functions, and it is
## recommended to have a separate file for each function.
##
## Subdirectories will also be scanned for *.sh, so you have no reason not
## to organize your code neatly.
##
create_cdk_to_proton_sh () {
  cat << BASH > cdk-to-proton.sh
#!/bin/bash
# cdk-outputs.json : { "stackName1" : { "outputName1" : "outputValue1" , "outputName2" : "outputValue2" }}
# proton-outputs.json : [ {"key": "outputName1" , "valueString" : "outputValue1" }, {"key": "outputName2" , "valueString" : "outputValue2" }]

jq 'to_entries | map_values(.value) | add | to_entries | map({key:.key, valueString:.value})'

BASH
  chmod 755 cdk-to-proton.sh
}

create_template_registration () {
  local target="$1"
  cat << YAML > .template-registration
compatible_environments:
  - $target
YAML
}


create_environment_schema () {
  cat << YAML > schema.yaml
schema:
  format:
    openapi: "3.0.0"
  environment_input_type: "EnvironmentInputs"
  types:
    EnvironmentInputs:
      type: object
      description: "Input properties for my environment"
      properties:
        vpc_cidr_block:
          type: string
          title: "VPC CIDR block"
          description: "VPC CIDR block, or default if left blank"
          default: "10.0.0.0/16"
      required:
        - vpc_cidr_block
YAML
}

create_service_schema () {
  cat << YAML > schema.yaml
schema:
  format:
    openapi: "3.0.0"
  service_input_type: "ServiceInputs"
  types:
    ServiceInputs:
      type: object
      description: "Input properties for my service"
      properties:
        subnet_cidr_block:
          type: string
          title: "VPC CIDR block"
          description: "VPC CIDR block, or default if left blank"
          default: "10.0.0.0/24"
      required:
        - subnet_cidr_block
YAML
}

create_environment_manifest_yaml() {
cat << YAML > manifest.yaml
infrastructure:
  templates:
    - rendering_engine: codebuild
      settings:
        image: aws/codebuild/amazonlinux2-x86_64-standard:5.0
        runtimes:
          nodejs: 18
        provision:
          # Run when create/update is triggered for environment or service
          # Install dependencies
          - npm install
          - npm run cdk -- deploy
          # Script to convert CDK outputs into outputs for Proton
          - chmod +x ./cdk-to-proton.sh
          - cat cdk-outputs.json | ./cdk-to-proton.sh > proton-outputs.json
          # Notify AWS Proton of deployment status
          - aws proton notify-resource-deployment-status-change --resource-arn \$RESOURCE_ARN --outputs file://./proton-outputs.json
        deprovision:
          # Install dependencies and destroy resources
          - npm install
          - npm run cdk -- destroy --force
YAML
}

create_service_manifest_yaml() {
cat << YAML > manifest.yaml
infrastructure:
  templates:
    - rendering_engine: codebuild
      settings:
        image: aws/codebuild/amazonlinux2-x86_64-standard:5.0
        runtimes:
          nodejs: 18
        provision:
          # Run when create/update is triggered for environment or service
          # Install dependencies
          - npm install
          - npm run cdk -- deploy
          # Script to convert CDK outputs into outputs for Proton
          - chmod +x ./cdk-to-proton.sh
          - cat cdk-outputs.json | ./cdk-to-proton.sh > proton-outputs.json
          # Notify AWS Proton of deployment status
          - aws proton notify-resource-deployment-status-change --resource-arn \$RESOURCE_ARN --outputs file://./proton-outputs.json
        deprovision:
          # Install dependencies and destroy resources
          - npm install
          - npm run cdk -- destroy --force
YAML
}


