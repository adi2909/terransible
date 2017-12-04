# Access key and Secret can be passed via Credentials file or Environment Variables
# Generally I pass them as environment variables

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"

  region = "${var.aws_region}"
}

