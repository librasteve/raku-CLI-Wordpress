class Build {
    method build($dist-path) {
        
        chdir $*HOME;
        mkdir '.rawp-config';
        chdir '.rawp-config';
        
my $text1 = q:to/END1/;
instance:
    #image: ami-0f540e9f488cfa27d            # <== the standard, clean AWS Ubuntu
    image: ami-0c1163e529aeb9b20            # <== AWS Ubuntu plus raws-ec2 setup already applied (use --nsu flag)
    #type: t2.micro                          # <== the basic, free tier eligible machine (12 credits/hr)
    type: t3.medium                         # <== a step above t2.micro for more beefy server needs
    #type: c6a.4xlarge                       # <== a mega machine for benchmarking
    storage: 30                             # <== EBS size for launch
    security-group:
        name: MySG
        rules:
            - inbound:
                port: 22
                cidr: 0.0.0.0/0
            - inbound:
                port: 80
                cidr: 0.0.0.0/0
            - inbound:
                port: 443
                cidr: 0.0.0.0/0
            - inbound:
                port: 8080
                cidr: 0.0.0.0/0
            - inbound:
                port: 8888
                cidr: 0.0.0.0/0
END1

        qqx`echo \'$text1\' > wordpress-launch.yaml`;
        
        warn 'Build successful';
        
        exit 0
    }
}
