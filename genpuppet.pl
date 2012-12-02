#!/usr/bin/perl

use Data::Dumper;

our %types, %resources;
our @configs, @requires, @includes;
our $manifest, $classname;
our $include=0, $nullmailer=0, $semaphore=0;
my $var, $figfile = "./genpuppet.conf";
#my @atomic = ( ensure, mode, owner, group, source, content, logoutput );
my @metaparms = ('before','require','subscribe','notify','recipient','options','groups');


#
# start genpuppet.pl
#
print "Name of manifest? "; chomp ($manifest = <>);
open FP, ">$manifest";

print "Name of class? "; chomp ($classname = <>);
printf FP "class $classname {\n";

@configs = load_config();

do_toplevel();
get_resources();
write_manifest();
write_swatch();

# write end class
#
printf FP "}\n";
close FP;


sub load_config {
    my @ary;

    open (FIGS, "$figfile") || die ("Error opening $figfile\n");
    @ary = <FIGS>;
    close (FIGS);
    return (@ary);
}


#
# Get as many top-level requires and includes as necessary
# Grok class nullmailer params
#
sub do_toplevel {
    my $a, $r;

    print "Top level require? "; chomp ($var = <>);
    while ($var) {
        push (@requires, $var);
        print "Top level require? "; chomp ($var = <>);
    }
    while (@requires) {
        $var = shift (@requires);

        printf FP "    require $var\n";
    }
    if ($var) { printf FP "\n"; }


    print "Top level include? "; chomp ($var = <>);
    while ($var) {
        push (@includes, $var);
        print "Top level include? "; chomp ($var = <>);
    }
    while (@includes) {
        $var = shift (@includes);

        printf FP "    include $var\n";
    }
    if ($var) { printf FP "\n"; }


    print "Use class nullmailer? [no] "; chomp ($var = <>);
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

    print "Use exec set-semaphore? [no] "; chomp ($var = <>);
    if ($var) { $semaphore=1; }
}
# end do_toplevel()


sub get_resources {
    my @figs = @configs;

    while (@figs) {
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

                #if (grep /$attr/, @atomic) { 
                if (! grep /$attr/, @metaparms) { 
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
        print "\n";
    } # end while
} # end get_resources()


sub write_manifest {
    my @figs = @configs;

    while (@figs) {
        my $line  = shift (@figs);
        my @x     = split (": ", $line);
        my $rs    = @x[0];
        my @savep = split (", ", @x[1]);


        foreach my $rsname (reverse keys %{ $resources{$rs} }) {
            my @params = @savep;
            chomp(@params);

            printf FP "    $rs { '$rsname':\n";

            while (@params) {
                my $attr = shift (@params);

                if (grep /$attr/, @metaparms) { 
                    if (defined $resources{$rs}{$rsname}{$attr}) {
                        printf FP "        $attr => [\n";

                        while (@{ $resources{$rs}{$rsname}{$attr} }) {
                            my $mp = 
                                shift (@{ $resources{$rs}{$rsname}{$attr} });

                            printf FP "            $mp,\n";
                        }
                        printf FP "        ],\n";
                    }
                }
                elsif ($resources{$rs}{$rsname}{$attr}) {
                        printf FP
                        "        $attr => $resources{$rs}{$rsname}{$attr},\n";
                }
            }
        print FP "    }\n";
        }
    }
    print FP "\n\n";
} # end write_manifest()


sub write_swatch {
    return if ($semaphore);
}
