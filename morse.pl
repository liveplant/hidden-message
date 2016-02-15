#!/usr/bin/perl

use warnings;
use strict;

my $needle = "*-*";
my $haystack = "*-_-***";

#my $haystack = "****_*_*-**_*-**_---___*--_---_*-*_*-**_-**";
#my $needle = "****_*_*-**_*--*";

print "Haystack: $haystack\n";
print "Needle: $needle\n\n";

sub printArray { 
   print "[";
   my $aryRef = shift;
   for my $subAry (@$aryRef) {
     print "[" . join(", ", @$subAry) . "]";
   }
   print "]\n";
}

sub validMatch {
	my $arrayRef = shift;
	my $valid = 1;
	for my $i (@$arrayRef) {
		if($i == -1) {
			$valid = 0;
		}
	}
	return $valid;
}

sub array_index { #array elements should be numeric
	my $haystack = shift;
	my $needle = shift;
	my @haystackAry = @$haystack;
	for(my $i = 0; $i < scalar @haystackAry; $i++) {
		if($needle == $haystackAry[$i]) {
			return $i;
		}
	}
	return -1;
}

sub next_hit {
	my $hitsRef = shift;
	my $start = shift;
	
	my $hitlen = scalar @$hitsRef;
	
	my @startAry;
	if(defined $start) {
		@startAry = @$start;
	} else {
		@startAry[0..$hitlen-1] = (0) x $hitlen;
		return \@startAry;
	}
	
	my @hits = @$hitsRef;
	
	my $index = $hitlen-1;
	while($index > 0) {
		my @hit = @{$hits[$index]};
		$startAry[$index]++;
		if($startAry[$index] >= scalar @hit) {
			$startAry[$index] = 0;
			$index--;
		} else {
			return \@startAry;
		}
	}
	return 0;
}

sub parse_hit {
	my $hitIndex = shift;
	my @hits = @{+shift};
	
	my @result = ();
	my $i=0;
	for my $index (@$hitIndex) {
		my @hit = @{$hits[$i]};
		$result[$i++] = $hit[$index];
	}
	return @result;
}

sub remove_hit_from_haystack {
	my $hit = shift;
	my $haystack = shift;
	my $hits = shift;
	
	my $i=0;
	for my $charpos (parse_hit($hit, $hits)) {
		$haystack = substr($haystack, 0, $charpos-$i) . substr($haystack, $charpos+1-$i);
		$i++;
	}
	return $haystack;
}

my @nAry = split //, $needle; #array of needle characters

#initialize the "hits" array
my @hits = ();
for(my $i = 0; $i < scalar @nAry; $i++) {
	$hits[$i] = [];
}

for(my $baseIndex = 0; $baseIndex < scalar @nAry; $baseIndex++) {

	my $hitAry = $hits[$baseIndex];
	my $startPos = scalar @$hitAry == 0 ? 0 : @$hitAry[-1] + 1; 
	while($startPos < length $haystack) {
		my @matches = ();
		#init matches array
		for(my $mIndex = 0; $mIndex < $baseIndex; $mIndex++) {
			my @hitAry = @{$hits[$mIndex]};
			$matches[$mIndex] = $hitAry[-1];
		}
		
		my $validMatch = 1;
		for(my $seekIndex = $baseIndex; $seekIndex  < scalar @nAry; $seekIndex ++) {
			my $needleC = $nAry[$seekIndex ];
			my $pos = scalar @matches == $baseIndex ? $startPos : $matches[-1]+1;
			my $ind = index($haystack, $needleC, $pos);
			if($ind == -1) {
				$validMatch = 0;
				last;
			} else {
				$matches[$seekIndex ] = $ind;
			}
		}
		if($validMatch) {
			$startPos = $matches[$baseIndex]+1;
			my $i=0;
			for(my $i=0; $i< scalar @matches; $i++) {
				if(array_index($hits[$i], $matches[$i]) == -1) {
					push(@{$hits[$i]}, $matches[$i]);
				}
			}
		} else {
			last; #if valid match is false, then we move onto next character in needle
		}
	}
	
}

print "Removal Matrix:\n";
printArray(\@hits);
print "\n";

my @uniquecodes = ();

my $nextHit = next_hit \@hits;;

do {
	#this loop is where the slowdown happens...
	#The generation of the removal matix is nearly instantaneous
	#You should be able to make this more efficient by only comparing
	#strings at the positions where you've removed a character.  Comparing
	#the entire string (like below) is inefficient.
	
	my $code = remove_hit_from_haystack($nextHit, $haystack, \@hits);
	my $codeExists = 0;
	for my $uc (@uniquecodes) {
		if($uc eq $code) {
			$codeExists = 1;
			last;
		}
	}
	if(!$codeExists) {
		push(@uniquecodes, $code);
	}
	
	$nextHit = next_hit(\@hits, $nextHit);
	
} while($nextHit);

print "Unique Codes:\n";
for my $code (@uniquecodes) {
	print $code . "\n";
}

print "\nCode Count: " . scalar(@uniquecodes) . "\n";
