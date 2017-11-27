provider "aws" {
  region = "ap-northeast-1"
  endpoints {
    dynamodb = "http://localhost:8000"
  }
}

resource "aws_dynamodb_table" "Widgets" {
  name           = "Widgets"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "UserID"
  range_key      = "Time"

  attribute {
    name = "UserID"
    type = "N"
  }

  attribute {
    name = "Time"
    type = "N"
  }
}