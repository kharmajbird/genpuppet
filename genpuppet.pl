#!/usr/bin/perl

use Data::Dumper;

our %resources;
our @requires, @includes;
our $manifest, $classname;
our $include=0, $nullmailer=0, $semaphore=0;
my $var;


#
# start genpuppet.pl
#

print "Name of manifest? ";
chomp ($manifest = <>);
open FP, ">$manifest";

print "Name of class? ";
chomp ($classname = <>);
printf FP "class $classname {\n";

do_toplevel();
get_packages();
write_packages();
get_services();
write_services();
get_files();
write_files();
get_execs();
write_execs();
write_swatch();

# write end class
#
printf FP "}\n";
close FP;


#
# Get as many top-level requires and includes as necessary
# Grok class nullmailer or exec set-semaphore options
#
sub do_toplevel {
    my $a, $r;

    print "Top level require? ";
    chomp ($var = <>);

    while ($var) {
        push (@requires, $var);
        print "Top level require? ";
        chomp ($var = <>);
    }
    while (@requires) {
        my $inc = shift (@requires);

        printf FP "    require $inc\n";
    }
    printf FP "\n";


    print "Top level include? ";
    chomp ($var = <>);

    while ($var) {
        push (@includes, $var);
        print "Top level include? ";
        chomp ($var = <>);
    }
    while (@includes) {
        my $inc = shift (@includes);

        printf FP "    include $inc\n";
    }
    printf FP "\n";


    print "Use class nullmailer? [no] ";
    chomp ($var = <>);
    if ($var) {
        print "adminaddr => ";
        chomp ($a = <>);
        print "remoterelay => ";
        chomp ($r = <>);

        printf FP "    class { 'nullmailer':\n";
	printf FP "        adminaddr => '$a',\n";
        printf FP "        remoterelay => '$r',\n";
        printf FP "    }\n\n";
    }


    print "Use exec set-semaphore? [no] ";
    chomp ($var = <>);

    # need to handle this just before the end of the class"
    #
    if ($var) { $semaphore=1; }
}
# end do_toplevel()


#
# get all package resources and their metaparameters
#
sub get_packages {
    my $pname, $var;

    print "Package name? ";
    chomp ($pname = <>);

    while ($pname) {
        my @before = (), @require = ();

        print "ensure => ";
        chomp ($resources{'package'}->{$pname}->{'ensure'} = <>);

        print "before => ";
        chomp ($var = <>);
        while ($var) {
            push (@before, $var);

            print "before => ";
            chomp ($var = <>);
        }
        if (@before) {
            @{ $resources{'package'}->{$pname}->{'before'} } = @before;
        }

        print "require => ";
        chomp ($var = <>);
        while ($var) {
            push (@require, $var);

            print "require => ";
            chomp ($var = <>);
        }
        if (@require) {
            @{ $resources{'package'}->{$pname}->{'require'} } = @require;
        }

        print "Package name? ";
        chomp ($pname = <>);
    }
}
# end get_packages()


#
# write package stanzas
#
sub write_packages {
    foreach my $var (reverse keys %{ $resources{'package'} }) {
        printf FP "    package { '$var':\n";
        printf FP "        ensure => $resources{'package'}{$var}{'ensure'},\n";
    
        # do before =>
        #
        if ($resources{'package'}{$var}{'before'}) {
            my @ary = @{ $resources{'package'}{$var}{'before'} };
    
            printf FP "        before => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }
    
        # do require =>
        #
        if ($resources{'package'}{$var}{'require'}) {
            my @ary = @{ $resources{'package'}{$var}{'require'} };
    
            printf FP "        require => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }
        printf FP "    }\n";
    }
    printf FP "\n\n";
}
# end write_packages()


#
#
#
sub get_services {
    my $sname, $var;

    print "Service name? ";
    chomp ($sname = <>);

    while ($sname) {
        my @before = (), @require = ();

        print "ensure => ";
        chomp ($resources{'service'}->{$sname}->{'ensure'} = <>);

        print "before => ";
        chomp ($var = <>);
        while ($var) {
            push (@before, $var);

            print "before => ";
            chomp ($var = <>);
        }
        if (@before) {
            @{ $resources{'service'}->{$sname}->{'before'} } = @before;
        }

        print "require => ";
        chomp ($var = <>);
        while ($var) {
            push (@require, $var);

            print "require => ";
            chomp ($var = <>);
        }
        if (@require) {
            @{ $resources{'service'}->{$sname}->{'require'} } = @require;
        }

        print "Service name? ";
        chomp ($sname = <>);
    }
}
# end get_services()

#
# write service stanzas
#
sub write_services {
    foreach my $var (reverse keys %{ $resources{'service'} }) {
        printf FP "    service { '$var':\n";
        printf FP "        ensure => $resources{'service'}{$var}{'ensure'},\n";
    
        # do before =>
        #
        if ($resources{'service'}{$var}{'before'}) {
            my @ary = @{ $resources{'service'}{$var}{'before'} };
    
            printf FP "        before => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }
    
        # do require =>
        #
        if ($resources{'service'}{$var}{'require'}) {
            my @ary = @{ $resources{'service'}{$var}{'require'} };
    
            printf FP "        require => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }
        printf FP "    }\n";
    }
    printf FP "\n\n";
}
# end write_services()


#       
# get all file resources and their metaparameters
#       
sub get_files {
    my $fname;
    my $var;

    print "File path? ";
    chomp ($fname = <>);

    while ($fname) {
        my @before = (), @require = ();

        print "ensure => ";
        chomp ($resources{'file'}->{$fname}->{'ensure'} = <>);

        print "owner => ";
        chomp ($resources{'file'}->{$fname}->{'owner'} = <>);

        print "group => ";
        chomp ($resources{'file'}->{$fname}->{'group'} = <>);

        print "mode => ";
        chomp ($resources{'file'}->{$fname}->{'mode'} = <>);

        print "source => ";
        chomp ($resources{'file'}->{$fname}->{'source'} = <>);

        print "content => ";
        chomp ($resources{'file'}->{$fname}->{'content'} = <>);
 
        print "before => ";
        chomp ($var = <>);
        while ($var) {
            push (@before, $var);
                
            print "before => ";        
            chomp ($var = <>);
        }   
        if (@before) {
            @{ $resources{'file'}->{$fname}->{'before'} } = @before;
        } 
        
        print "require => ";
        chomp ($var = <>);
        while ($var) {
            push (@require, $var);
            
            print "require => ";
            chomp ($var = <>);         
        }   
        if (@require) {        
            @{ $resources{'file'}->{$fname}->{'require'} } = @require;
        }
   
        print "File path? ";
        chomp ($fname = <>);
    }
} 
# end get_files()


#
# write file stanzas
#
sub write_files {
    foreach my $var (reverse keys %{ $resources{'file'} }) {
        printf FP "    file { '$var':\n";

        if ($resources{'file'}{$var}{'ensure'}) {
            printf FP 
            "        ensure => '$resources{'file'}{$var}{'ensure'}',\n";
        }
        if ($resources{'file'}{$var}{'owner'}) {
            printf FP 
            "        owner => '$resources{'file'}{$var}{'owner'}',\n";
        }
        if ($resources{'file'}{$var}{'group'}) {
            printf FP 
            "        group => '$resources{'file'}{$var}{'group'}',\n";
        }
        if ($resources{'file'}{$var}{'mode'}) {
            printf FP 
            "        mode => '$resources{'file'}{$var}{'mode'}',\n";
        }
        if ($resources{'file'}{$var}{'source'}) {
            printf FP 
            "        source => '$resources{'file'}{$var}{'source'}',\n";
        }
        if ($resources{'file'}{$var}{'content'}) {
            printf FP 
            "        content => $resources{'file'}{$var}{'content'},\n";
        }

        # do before =>
        #
        if ($resources{'file'}{$var}{'before'}) {
            my @ary = @{ $resources{'file'}{$var}{'before'} };

            printf FP "        before => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }

        # do require =>
        #
        if ($resources{'file'}{$var}{'require'}) {
            my @ary = @{ $resources{'file'}{$var}{'require'} };

            printf FP "        require => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }
        printf FP "    }\n";
    }
    printf FP "\n\n";
}
# end write_files()

#
#
#
sub get_execs {
    my $exec, $var;

    print "Exec name? ";
    chomp ($exec = <>);

    while ($exec) {
        my @before = (), @require = ();

        print "command => ";
        chomp ($resources{'exec'}->{$exec}->{'command'} = <>);

        print "logoutput => ";
        chomp ($resources{'exec'}->{$exec}->{'logoutput'} = <>);

        print "onlyif => ";
        chomp ($resources{'exec'}->{$exec}->{'onlyif'} = <>);

        print "unless => ";
        chomp ($resources{'exec'}->{$exec}->{'unless'} = <>);

        print "creates => ";
        chomp ($resources{'exec'}->{$exec}->{'creates'} = <>);

        print "before => ";
        chomp ($var = <>);
        while ($var) {
            push (@before, $var);
                
            print "before => ";        
            chomp ($var = <>);
        }   
        if (@before) {
            @{ $resources{'exec'}->{$exec}->{'before'} } = @before;
        } 
        
        print "require => ";
        chomp ($var = <>);
        while ($var) {
            push (@require, $var);
            
            print "require => ";
            chomp ($var = <>);         
        }   
        if (@require) {        
            @{ $resources{'exec'}->{$exec}->{'require'} } = @require;
        }
   
        print "Exec name? ";
        chomp ($exec = <>);
    }
}
# end get_execs()


#
#
#
sub write_execs {
    foreach my $var (reverse keys %{ $resources{'exec'} }) {
        printf FP "    exec { '$var':\n";

        if ($resources{'exec'}{$var}{'command'}) {
            printf FP 
            "        command => '$resources{'exec'}{$var}{'command'}',\n";
        }
        if ($resources{'exec'}{$var}{'logoutput'}) {
            printf FP 
            "        logoutput => '$resources{'exec'}{$var}{'logoutput'}',\n";
        }
        if ($resources{'exec'}{$var}{'onlyif'}) {
            printf FP 
            "        onlyif => '$resources{'exec'}{$var}{'onlyif'}',\n";
        }
        if ($resources{'exec'}{$var}{'unless'}) {
            printf FP 
            "        unless => '$resources{'exec'}{$var}{'unless'}',\n";
        }
        if ($resources{'exec'}{$var}{'creates'}) {
            printf FP 
            "        creates => '$resources{'exec'}{$var}{'creates'}',\n";
        }

        # do before =>
        #
        if ($resources{'exec'}{$var}{'before'}) {
            my @ary = @{ $resources{'exec'}{$var}{'before'} };

            printf FP "        before => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }

        # do require =>
        #
        if ($resources{'exec'}{$var}{'require'}) {
            my @ary = @{ $resources{'exec'}{$var}{'require'} };

            printf FP "        require => [\n";
            while (@ary) {
                my $bf = shift (@ary);
                printf FP "            $bf,\n";
            }
            printf FP "        ],\n";
        }
        printf FP "    }\n";
    }
    printf FP "\n\n";
}
# end write_execs()

#
#
#
sub write_swatch {
    return if ($semaphore);
}
