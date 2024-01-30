# Configurações básicas

terraform{
    required_version = ">= 0.12.25"
}

provider "aws"{
    region = "sa-east-1"
}

# Gerenciar recursos

resource "aws_s3_bucket" "bucket" {
    bucket = "terraform-initial-bucket"
}

resource "aws_sqs_queue" "queue"{
    name = "terraform-initial-queue"
    policy = data.aws_iam_policy_document.queue.json
    tags = {
        env = var.env
        conta = var.conta
    }
}

data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:terraform-initial-queue"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }
  }
}

resource "aws_s3_bucket_notification" "s3_notification" {
  bucket = aws_s3_bucket.bucket.id

  queue {
    events    = ["s3:ObjectCreated:*"]
    queue_arn = aws_sqs_queue.queue.arn
    filter_prefix = "files/"
  }
}

