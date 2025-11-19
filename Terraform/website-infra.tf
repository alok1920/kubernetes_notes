# we will write everything in blocks inside the tf file.

provider "aws" {
  region = "ap-south-1"
}

# create a vpc
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" 
  tags = {
    Name = "WebsiteVPC"
  }
}

# create a subnet
resource "aws_subnet" "mySubnet" {
    vpc_id = aws_vpc.my_vpc.id
    cidr_block = "10.0.0.0/16"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true
    tags = {
      Name = "WebsiteSubnet"
    }
}

# create a IG
resource "aws_internet_gateway" "MyInternateGateway" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "WebsiteIG"
  }
}

# create a route table
resource "aws_route_table" "MyRouteTable" {
  vpc_id = aws_vpc.my_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.MyInternateGateway.id
  }
  tags = {
    Name = "WebsiteRouteTable"
  }
}

# coonect subnet to route table
resource "aws_route_table_association" "MyRouteTableAssociation" {
  subnet_id = aws_subnet.mySubnet.id
  route_table_id = aws_route_table.MyRouteTable.id
}

# create EC2 instances
resource "aws_instance" "MyInstance" {
  count = 4
  ami = "ami_id/of/operatingSystem/you/want/to/use" # example for ubuntu the ami id is 
  instance_type = "t2.medium" # as we are running website we need a bit strong proceesing so we used t2.medium insted of t2.micro
  key_name="abcd" # you can give any name of you key pair
  tags = {
    Name = "MyEC2-${count.index + 1}" # we need to name the instance as MyEC2-1, MyEC2-2 so we used "-count.index + 1" as index start with 0 we gave "+ 1"
  }
  subnet_id = aws_subnet.mySubnet.id
  vpc_security_group_ids = [ aws_security_group.MySecurityGroup.id ]
}

# create a security group
# for three EC2 instance to get access from local we need to open port 22
resource "aws_security_group" "MySecurityGroup" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyProjectSG"
  }
  # inbound rule
  ingress = {
    description = "SHH Access"
    from_port = 22
    to_port = 25
    protocol = "tcp"
    cider_blocks = ["0.0.0.0/0"]
  }
  # outbound rule
  egress = {
    from_port = 0 # 0 means all traffic
    to_port = 0
    protocol = "-1" # -1 means output of all the protocal will be redirected to user
    cider_blocks = ["0.0.0.0/0"]
  }
}