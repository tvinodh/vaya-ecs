resource "aws_lb" "main" {
  name               = "${var.name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.alb.*.id
  subnets            = aws_subnet.public_subnets.*.id

  enable_deletion_protection = false

  tags = {
    Name = "${var.name}-alb"
  }
}

resource "aws_alb_target_group" "main" {
  name        = "${var.name}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  depends_on  = [aws_lb.main]

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name = "${var.name}-tg"
  }
}

# Redirect to https listener
resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.main.arn

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


/*

# Redirect traffic to target group
resource "aws_alb_listener" "http1" {
    load_balancer_arn = aws_lb.main.id
    port              = 80
    protocol          = "HTTP"


    default_action {
        target_group_arn = aws_alb_target_group.main.id
        type             = "forward"
    }
}
*/
/*
output "aws_alb_target_group_arn" {
  value = aws_alb_target_group.main.arn
}
*/
