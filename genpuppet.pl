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
get_files();
write_files();

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


#
# get all package resources and their metaparameters
#
sub get_packages {
    my $pname, $ensure;
    my $var;

    print "Package name? ";
    chomp ($pname = <>);

    while ($pname) {
        my @before = (), @require = ();

        print "ensure => ";
        chomp ($var = <>);

        if ($var) {
            $resources{'package'}->{$pname}->{'ensure'} = $var;
        }

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
}


#       
# get all file resources and their metaparameters
#       
sub get_files {
    my $fname, $ensure;
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

#
# write file stanzas
#
sub write_files {
    foreach my $var (reverse keys %{ $resources{'file'} }) {
        printf FP "    file { '$var':\n";
        printf FP "        ensure => '$resources{'file'}{$var}{'ensure'}',\n";
        printf FP "        owner => '$resources{'file'}{$var}{'owner'}',\n";
        printf FP "        group => '$resources{'file'}{$var}{'group'}',\n";
        printf FP "        mode => '$resources{'file'}{$var}{'mode'}',\n";
        printf FP "        source => '$resources{'file'}{$var}{'source'}',\n";
        printf FP "        content => $resources{'file'}{$var}{'content'},\n";

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
}
