# RDS requires a subnet group with subnets in at least 2 Availability Zones.
# We will create a secondary private subnet in a different AZ just for this requirement.

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private_secondary" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1] # Use a different AZ

  tags = {
    Name = "devops-challenge-private-subnet-2"
  }
}

resource "aws_db_subnet_group" "default" {
  name       = "devops-challenge-db-subnet-group"
  subnet_ids = [aws_subnet.private.id, aws_subnet.private_secondary.id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20
  db_name                = "laraveldb"
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  publicly_accessible    = false
  availability_zone      = var.availability_zone # Force primary AZ as requested

  tags = {
    Name = "devops-challenge-db"
  }
}
