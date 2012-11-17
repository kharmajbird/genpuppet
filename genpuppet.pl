#!/usr/bin/perl

my %resources;
my @requires, @includes;
my $manifest, $classname;
my $var, $include=0, $nullmailer=0, $semaphore=0;



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

