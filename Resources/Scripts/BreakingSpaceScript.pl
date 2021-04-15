use strict;
use locale;
my $src_root = $ENV{'SRCROOT'};
my $target_filepath = shift(@ARGV);
my $regex = qr/(?:^|\s)(не|в|во|без|до|из|к|на|по|о|от|перед|при|через|с|у|за|над|об|под|про|для|а|что|чтобы|и|да|как|но|или|0|1|2|3|4|5|6|7|8|9|ноль|один|два|три|четыре|пять|шесть|семь|восемь|девять|я|ты|мы|вы|он|она|оно|они|мне|тебе|ей|ему|им) /;
open(f, '<', $target_filepath) or die $!;
while(my $line = <f>) {
    next if($line =~ /^\s*$/);
    my @matches = $line =~ m/$regex/gi;
    foreach (@matches) {
        print "$target_filepath:$.: warning: \Breaking space used with preposition: $_\n";
    }
}
close f;
