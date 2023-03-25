class Build {
    method build($dist-path) {
        
        chdir $*HOME;
        mkdir '.rawp-config';
        chdir '.rawp-config';
        
my $text1 = q:to/END1/;
instance:
    domain-name: 'furnival.net'
    admin-email: 'hccs@furnival.net'
END1

        qqx`echo \'$text1\' > wordpress-launch.yaml`;
        
        warn 'Build successful';
        
        exit 0
    }
}
