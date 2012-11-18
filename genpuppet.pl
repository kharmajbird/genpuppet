#!/usr/bin/perl

use Data::Dumper;

our %resources;
our @requires, @includes;
our $manifest, $classname;
our $include=0, $nullmailer=0, $semaphore=0;
my $var;



print "Name of manifest? ";
chomp ($manifest = <>);

print "Name of class? ";
chomp ($classname = <>);


# get as many top-level requires and includes as necessary
#
print "Top level require? ";
chomp ($var = <>);

while ($var) {
    push (@requires, $var);
    print "Top level require? ";
    chomp ($var = <>);
}

print "Top level include? ";
chomp ($var = <>);

while ($var) {
    push (@include, $var);
    print "Top level include? ";
    chomp ($var = <>);
}


# Use class nullmailer or exec set-semaphore?
#
print "Use class nullmailer? [no] ";
chomp ($var = <>);
if ($var) { $nullmailer=1; }

print "Use exec set-semaphore? [no] ";
chomp ($var = <>);
if ($var) { $semaphore=1; }

get_packages();




open FP, ">$manifest";

printf FP "class $classname {\n";

while (@requires) {
    my $req = shift (@requires);

    printf FP "    require $req\n";
}
printf FP "\n";

while (@includes) {
    my $inc = shift (@includes);

    printf FP "    include $inc\n";
}
printf FP "\n";

if ($nullmailer) {
    printf FP "    class 'nullmailer': {\n";
    printf FP "        admin => jlewis@pavlovmedia.com,\n";
    printf FP "        relay => mail@pavlovmedia.com,\n";
    printf FP "    }\n\n";
}




# write package stanzas


foreach my $var (reverse keys $resources {'package'}) {
    printf FP "    package { '$var':\n";
    printf FP "        ensure => $resources{'package'}{$var}{'ensure'},\n";

    if ($resources{'package'}{$var}{'before'}) {
        my @ary = $resources{'package'}{$var}{'before'};

        printf FP "        before => [\n";

        while (@ary) {
            my $bf = shift (@ary);
            printf FP "            $bf,\n";
        }
        printf FP "        ],\n";
    }
    printf FP "    }\n\n";
}




# write end class
printf FP "}\n";

close FP;


print Dumper (%resources);

#
# get "package" resources and all metaparameters
#
sub get_packages {
    my $pname, $ensure, @require, @before;
    my $var;

    print "Package name? ";
    chomp ($pname = <>);

    while ($pname) {
        print "ensure => ";
        chomp ($var = <>);

        $resources  {'package'} -> {$pname} -> {'ensure'} = $var;

        print "before => ";
        chomp ($var = <>);
        while ($var) {
            push (@before, $var);

            print "before => ";
            chomp ($var = <>);
        }
        #$resources  {'package'} -> {$pname} -> {'before'} = \@before;
        $resources  {'package'} -> {$pname} -> {'before'} = @before;

        print "require => ";
        chomp ($var = <>);
        while ($var) {
            push (@require, $var);

            print "require => ";
            chomp ($var = <>);
        }
        #$resources  {'package'} -> {$pname} -> {'require'} = \@require;
        $resources  {'package'} -> {$pname} -> {'require'} = @require;

        print "Package name? ";
        chomp ($pname = <>);
    }
}
