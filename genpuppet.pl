#!/usr/bin/perl

use Data::Dumper;

our %types, %resources;
our @figs, @requires, @includes;
our $manifest, $classname;
our $include=0, $nullmailer=0, $semaphore=0;
my $var, $figfile = "./genpuppet.conf";
my @atomic = 
    ( ensure, mode, owner, group, source, content, logoutput );

my @metaparms = [ 'before', 'require' ];


#
# start genpuppet.pl
#


print "Name of manifest? ";
chomp ($manifest = <>);
open FP, ">$manifest";

print "Name of class? ";
chomp ($classname = <>);
printf FP "class $classname {\n";

@figs = load_config();

do_toplevel();
get_types();
write_manifest();
write_swatch();

# write end class
#
printf FP "}\n";
close FP;


#
#
#
sub load_config {
    my @ary;

    open (FIGS, "$figfile") || die ("Error opening $figfile\n");
    @ary = <FIGS>;
    close (FIGS);
    return (@ary);
}



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
    if (@requires) { printf FP "\n"; }


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
    if (@includes) { printf FP "\n"; }


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
    if ($var) { $semaphore=1; }
}
# end do_toplevel()


#
#
#
sub get_types {
    while (@figs) {
        my @before = (), @require = (), @savep = ();
        my $rsname, $resp;

        my $line  = shift (@figs);
        my @x     = split (": ", $line);
        my $rs    = @x[0];
        my @savep = split (", ", @x[1]);

        print "${rs}? ";
        chomp($rsname = <>);

        while ($rsname) {
            my @params = @savep;
            chomp(@params);

            while (@params) {
                my @ary = ();
                my $attr = shift (@params);

                print "${attr} => ";
                chomp ($resp = <>);

                if (grep /$attr/, @atomic) { 
                    if ($resp) { $resources{$rs}->{$rsname}->{$attr} = $resp; }
                }
                else {
                    while ($resp) {
                        push (@ary, $resp);
                
                        print "${attr} => ";        
                        chomp ($resp = <>);
                    }   
                    if (@ary) {
                        @{ $resources{$rs}->{$rsname}->{$attr} } = @ary;
                    } 
                }
            }
            print "${rs}? ";
            chomp($rsname = <>);
        }
    } # end while
} # end get_types()


#
#
#
sub write_manifest {
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
} # end write_manifest()



#
#
#
sub write_swatch {
    return if ($semaphore);
}
