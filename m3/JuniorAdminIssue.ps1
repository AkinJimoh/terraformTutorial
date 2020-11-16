#Select the AWS profile anna-prod
Set-AWSCredential -ProfileName "anna-prod"

#Set the default region as applicable
$region = "eu-west-2"
Set-DefaultAWSRegion -Region $region

#Get the VPC and AZs
#This assumes you used anna1 for the name of the VPC
$vpc = Get-EC2Vpc -Filter @{Name="tag:Name"; Values="anna1"}
$azs = Get-EC2AvailabilityZone
$az = ($azs | Sort-Object -Property ZoneName)[2]

#Create two new subnets in the third AZ
$privateSubnet = New-EC2Subnet -AvailabilityZone $az.ZoneName `
     -CidrBlock "10.0.12.0/24" -VpcId $vpc.VpcId
$publicSubnet = New-EC2Subnet -AvailabilityZone $az.ZoneName `
     -CidrBlock "10.0.2.0/24" -VpcId $vpc.VpcId

#Get the Public route table for all public subnets and associate the new public subnet
$publicRouteTable = Get-EC2RouteTable `
     -Filter @{ Name="tag:Name"; values="anna1-public"} -Region $region
$publicRouteTableAssociation = Register-EC2RouteTable `
     -RouteTableId $publicRouteTable.RouteTableId -SubnetId $publicSubnet.SubnetId

#Create a route table for the new private subnet and send traffic through the NAT Gateway
$privateRouteTable = New-EC2RouteTable -VpcId $vpc.VpcId
Register-EC2RouteTable -RouteTableId $privateRouteTable.RouteTableId `
     -SubnetId $privateSubnet.SubnetId

Write-Output "Oh Jimmy, what did you do?"

$JimmysResources = @{}
$JimmysResources.Add("privateSubnet",$privateSubnet.SubnetId)
$JimmysResources.Add("publicSubnet",$publicSubnet.SubnetId)
$JimmysResources.Add("privateRouteTable",$privateRouteTable.RouteTableId)
$JimmysResources.Add("privateRouteTableAssoc","$($privateSubnet.SubnetId)/$($privateRouteTable.RouteTableId)")
$JimmysResources.Add("publicRouteTableAssoc","$($publicSubnet.SubnetId)/$($publicRouteTable.RouteTableId)")


Write-Output ($JimmysResources.GetEnumerator() | sort -Property Name)


