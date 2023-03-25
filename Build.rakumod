class Build {
    method build($dist-path) {
        
        chdir $*HOME;
        mkdir '.rawp-config';
        chdir '.rawp-config';
        
        my $text = q:to/END/;
        instance:
            domain-name: 'furnival.net'
            admin-email: 'hccs@furnival.net'
        END

        qqx`echo \'$text\' > wordpress-launch.yaml`;
        
        warn 'Build successful';
        
        exit 0
    }
}
