#!/usr/bin/env perl
# RecordJar stuff:
#
# These are functions to deal with the "record-jar" format
# described in Eric S. Raymond's "The Art of UNIX Programming":
#
#   http://catb.org/~esr/writings/taoup/html/ch05s02.html#id2906931
#
# The idea is to translate an array of Perl hashes into a flat ASCII
# format.  Each "record" maps to an anonymous hash and vice versa.
# It's assumed that the keys will match /[\w\-]+/
#
#
#       @array_of_lines = hashlist_to_recordjar(@array_of_hashes);
#
#               Lines in the array produced will be terminated
#               with '\n', so the function output can be given
#               directly to the "print" function.
# 
#
#       @array_of_hashes = recordjar_to_hashlist($multiline_scalars,
#                                               @arrays_of_lines);
#
#               Scalars and arrays passed to the function will be
#               treated as a single list and "join"d with '\n'
#               before processing.
#
# The record separator is a line matching /^%%?\s*$/
#
# A field begins with a line matching /^([\w\-]+)\s*\:\s*(.*\S)?\s*$/
# and may be followed by continuation lines matching /^\s+(.*\S)\s*$/
# (This means a key must begin the line and be followed by a colon,
# and that a blank line will end the value.)
#
# This implementation of record jar expects special characters to be
# encoded as HTML entities.  (No escape sequences.)

use Time::gmtime;
use POSIX qw(mktime);

sub hashlist_to_recordjar
{
#       All lines will be terminated with the single byte '\n'.
#       Lines which would exceed 75 characters should be split onto
#       multiple lines at whitespace boundaries, subsequent lines
#       beginning with some whitespace (which will be read back as
#       a single space).
#
#       Hash elements with keys which don't consist of alphanumerics
#       and hyphens are skipped.

        my (@array) = @_;

        my (@jar) = (
                "# mnemo data format version $CURRENT_FILE_FORMAT_VERSION\n",
                "# (Based on the record-jar format described in\n",
                "# The Art of UNIX Programming by Eric Raymond.)\n",
                "\n",
        );
        my ($hashref, %hash, $key);

        foreach $hashref (@array) {
                (%hash) = (&massage_hash_keys(%$hashref));
                foreach $key (&key_sort(keys(%hash))) {
                        unless ($key =~ /^[\w\-]+$/) {
                                warn("Malformed key \"$key\"");
                                next;
                        }
                        push(@jar, &field_wrap("$key: " . $hash{$key}));
                }
                push(@jar, "\%\%\n");
        }

        return @jar;
}

sub massage_hash_keys
{
        my (%hash) = @_;

        my ($key);

        foreach my $key (sort(keys(%hash))) {
                if ($key ne lc($key)) {
                        if (defined($hash{lc($key)})) {
                                warn("Duplicate field key \"$key\"");
                        }
                        $hash{lc($key)} = $hash{$key};  # STOMP!
                        undef($hash{$key});
                }
        }

        return %hash;
}

sub key_sort
{
        my (@raw_list) = sort(@_);

        my (@ordered_keys) = (
                'identilo',     # 'uuid',
                'matura',       # 'due',
                'pauxzo',       # 'interval',
                'tusxita',    # 'modified',
                'filtrovortoj', # 'filter_keywords',
                'demando',      # 'question',
                'respondo',     # 'answer',
                'inversebla',   # 'reverse',
                'saltita',      # (new) 'skipped',
        );

        my (@sorted_list) = ();
        foreach my $o_key (@ordered_keys) {
                my ($pattern) = "^$o_key";

                push(@sorted_list, sort(grep(/$pattern/, @raw_list)));
                @raw_list = grep($_ !~ /$pattern/, @raw_list);
        }
        push(@sorted_list, @raw_list);

        return @sorted_list;
}

sub field_wrap
{
        my (@in_lines) = split(/[\r\n]+/m, join(' ', @_));
        grep(s/(^\s+)|(\s+$)//g, @in_lines);

        my ($line_length) = 75;
        my ($indent) = ' ' x 8;

        my (@out) = ();

        for (my $l = 0; $l <= $#in_lines; $l++) {
                $line = (($l == 0)?'':$indent) . $in_lines[$l];
                if (length($line) < $line_length) {
                        push(@out, $line . "\n");
                } else {
                        my (@words) = split(/\s+/, $in_lines[$l]);
                        $line = (($l == 0)?'':$indent) . shift(@words);
                        while ($#words >= 0) {
                                if ((length($line . $words[0]) + 1)
                                                < $line_length) {
                                        $line .= ' ';
                                } else {
                                        push(@out, $line . "\n");
                                        $line = $indent;
                                }
                                $line .= shift(@words);
                        }
                        push(@out, $line . "\n");
                }
        }

        return @out;
}

sub recordjar_to_hashlist
{
        my ($str) = join("\n", '', @_, '');     # Concatenate, with bookends.
        $str =~ s/\s*[\r\n]/\n/mg;      # Condense EOLs and empties.
        $str =~ s/\n\s*\#[^\n]*\n/\n/;  # Remove comments.
        $str =~ s/\s*[\r\n]/\n/mg;      # Condense EOLs and empties, again.
        my (@lines) = split(/\s*\n/, $str);
        undef($str);

        my (@dataset) = ();
        my (%hash) = ();
        my ($key, $val);
        my ($this_line);
        my ($ext_val);

        while ($#lines >= 0) {
                $this_line = shift(@lines);
                # Detect record separator
                if ($this_line =~ /^\%{1,2}$/) {
                        # End of record.
                        push(@dataset, { %hash } );
                        %hash = ();
                        next;
                }

                if (($key, $val) = ($this_line =~ /^([\w\-]+)\s*\:\s*(.*\S)?\s*$/)) {
                        $key = lc($key);
                        while (($ext_val) = ($lines[0] =~ /^\s+(.*\S)\s*$/)) {
                                shift(@lines);
                                $val .= ("\n" . $ext_val);
                        }
                        if (defined($hash{$key})) {
                                warn("Duplicate field \"$key\"");
                        }
                        $hash{$key} = $val; # Stomps on old val same key.
                }
        }

        # Allow final record to omit record terminator.
        if (keys(%hash)) {
                push(@dataset, { %hash } );
        }

        return @dataset;
}

sub load_cards
{
        my ($card_file) = @_;

        @cards = ();

        my ($first_line) = `head -1 '$card_file'`;
        my ($version);

        if (($version) = ($first_line =~ /^\# mnemo data format version (\d+)/)) {
                if ($version > $CURRENT_FILE_FORMAT_VERSION) {
                        warn("\"$card_file\" postulas plinovan version de mnemo!\n");
                        warn("  (havas $version, sed komprenas $CURRENT_FILE_FORMAT_VERSION)\n");
                        @cards = ();
                } else {
                        if (open(CARDS, "<$card_file")) {
                                @cards = &recordjar_to_hashlist(<CARDS>);
                                close(CARDS);
                        }
                }
        } else {
                system("perl -c $card_file >/dev/null 2>/dev/null");
                if ($?) {
                        # mnemo data format version 1, or invalid.
                        @cards = ();
                } else {
                        # mnemo data format version 2:
                        my ($card_array_ref) = eval(`cat '$card_file'`);
                        foreach my $card_ref (@$card_array_ref) {
                                my(%card) = %{$card_ref};
                                defined($card{'question'})
                                && defined($card{'answer'}) || next;
                                push(@cards, {%card});
                        }
                }
        }

        # Sxangxi sxlosilojn al Esperanto.
        my(%esperantigilo) = (
                'uuid', 'identilo',
                'due', 'matura',
                'interval', 'pauxzo',
                'modified', 'tusxita', 'sxangxita', 'tusxita',
                'filter_keywords', 'filtrovortoj',
                'question', 'demando',
                'answer', 'respondo',
                'reverse', 'inversebla',
                'skipped', 'saltita',
        );
        foreach my $cardref (@cards) {
                foreach my $vorto (keys(%esperantigilo)) {
                        if (defined(${$cardref}{$vorto})) {
                                ${$cardref}{$esperantigilo{$vorto}} = ${$cardref}{$vorto};
                                delete(${$cardref}{$vorto});
                        }
                }
        }

        # Take care of "inversebla"
        my ($idx);
        for ($idx = 0; $idx <= $#cards; $idx++) {
                my ($cardref) = $cards[$idx];
                if (defined(${$cardref}{'inversebla'})) {
                        if (${$cardref}{'inversebla'}) {
                                my (%card) = &reverse_card(%{$cardref});
                                delete($card{'inversebla'});
                                if (defined($card{'identilo'})) {
                                        delete($card{'identilo'});
                                }
                                splice(@cards, $idx + 1, 0, {%card});
                        }
                        delete(${$cardref}{'inversebla'});
                }
        }

        # Expand macros,
        # forward-convert "content" field,
        # and create uuid if not there.
        foreach my $cardref (@cards) {
                if (defined(${$cardref}{'pauxzo'})) {
                        ${$cardref}{'pauxzo'} = 
                                &max(&macro_eval(${$cardref}{'pauxzo'}),
                                        $DEFAULT_MINIMUM_INTERVAL);
                }
                if (defined(${$cardref}{'matura'})) {
                        ${$cardref}{'matura'} = &read_due(${$cardref}{'matura'});
                } else {
                        ${$cardref}{'matura'} = 0;
                }
                if (defined(${$cardref}{'tusxita'})) {
                        ${$cardref}{'tusxita'} = &read_due(${$cardref}{'tusxita'});
                }
                if (defined(${$cardref}{'content'})) {
                        ${$cardref}{'filtrovortoj'} = ${$cardref}{'content'};
                        delete(${$cardref}{'content'});
                }
                unless (defined(${$cardref}{'identilo'})) {
                        ${$cardref}{'identilo'} = `uuidgen`;
                        chomp(${$cardref}{'identilo'});
                }
        }

        $gFileName = $card_file;
	$gFileName =~ s/\.mnemo$//;
}

sub macro_eval
{
        my ($str) = @_;

        my ($retval) = 0;
        my ($val, $macro);
        
        if ((($val, $macro) = ($str =~ /^\s*(\d+)\s+(\w+)\s*$/))
            && ($macro =~ /^(minuto)|(horo)|(tago)|(semajno)|(monato)|(jaro)|(minute)|(hour)|(day)|(week)|(month)|(year)s?$/i)) {
                $macro = uc($macro);
                $macro =~ s/J|S$//; # strip trailing "J" or "S".
                $retval = $val * $$macro;
        } elsif (($val) = ($str =~ /^\s*(\d+)\s*\(/)) {
                $retval = $val;
        }

        return $retval;
}

sub date_eval
{
        my ($str) = @_;

        my ($retval) = 0;
        my ($year, $month, $day);

        if (($year, $month, $day) = ($str =~ /^\s*(\d{4})[\.\-](\d{2})[\.\-](\d{2})\s*$/)) {
                # Use GMT noon on that day.
                $retval = POSIX::mktime(0,0,12,$day,$month-1,$year-1900);
        }

        return $retval;
}

sub write_interval
{
        my ($val) = @_;
        
        return $val . ' (' . &show_seconds($val) . ')';
}

sub read_due
{
        my ($str) = @_;

        my ($retval) = 0;
        my ($val);

        if (($val) = ($str =~ /^\s*(\d+)\s*\(?/)) {
                $retval = $val;
        } elsif ($str =~ /^\s*(nun)|(hodiaux)|(now)|(today)\s*$/i) {
                $retval = time - 1;
        } else {
                $retval = &macro_eval($str);
                if ($retval) {
                        $retval += time;
                }
        }

        unless ($retval) {
                $retval = &date_eval($str);
        }

        $retval = $retval ? $retval : (time - 1);

        return $retval;
}

sub read_modified
{
        my ($str) = @_;

        my ($val);

        if (($val) = ($str =~ /^\s*(\d+)\s*\(/)) {
                return $val;
        }

        return undef;
}

sub iso8601_date
{
        my ($val) = @_;

        my ($year, $month, $day) = (
                gmtime($val)->year() + 1900,
                gmtime($val)->mon() + 1,
                gmtime($val)->mday(),
        );

        # YYYY-MM-DD is ISO 8601 format. 
        return sprintf('%04d-%02d-%02d', $year, $month, $day);
}

sub iso8601_timestamp
{
        my ($val) = @_;

        my ($year, $month, $day, $hour, $minutes, $seconds) = (
                gmtime($val)->year() + 1900,
                gmtime($val)->mon() + 1,
                gmtime($val)->mday(),
                gmtime($val)->hour(),
                gmtime($val)->min(),
                gmtime($val)->sec(),
        );

        # "YYYY-MM-DD hh:mm:ss" is ISO 8601 format. 
        return sprintf('%04d-%02d-%02d %02d:%02d:%02d',
                $year, $month, $day, $hour, $minutes, $seconds);
}

sub reverse_card
{
        my (%old_card) = @_;

        my (%new_card) = ();
        my ($value);

        foreach my $key (keys(%old_card)) {
                $value = $old_card{$key};
                if ($key =~ /^demando/) {
                        $key =~ s/^demando/respondo/;
                } elsif ($key =~ /^respondo/) {
                        $key =~ s/^respondo/demando/;
                }
                $new_card{$key} = $value;
        }

        return %new_card;
}

sub save_cards
{
        my ($card_file) = @_;

        # Expand seconds-based values to human-readable form.
        foreach my $cardref (@cards) {
                if (defined(${$cardref}{'pauxzo'})) {
                        ${$cardref}{'pauxzo'} = 
                                &write_interval(${$cardref}{'pauxzo'});
                }
                if (defined(${$cardref}{'matura'})) {
                        ${$cardref}{'matura'} = 
                                ${$cardref}{'matura'} . ' (' .
                                &iso8601_date(${$cardref}{'matura'}) . ')';
                }
                if (defined(${$cardref}{'tusxita'})) {
                        ${$cardref}{'tusxita'} = 
                                ${$cardref}{'tusxita'} . ' (' .
                                &iso8601_date(${$cardref}{'tusxita'}) . ')';
                }
        }

        open(RECJAR, ">$card_file.new") ||
                die "Couldn't write \"$card_file.new\"\n";
        print RECJAR &hashlist_to_recordjar(@cards);
        close(RECJAR);
        # Clobber the old file with the new one as an atomic operation.
        rename("$card_file.new", "$card_file") ||
                die "Couldn't rename \"$card_file.new\" to \"$card_file\"\n";

        @cards = ();
}

sub show_seconds
{
        my ($seconds) = @_;

        my ($minutes) = int($seconds / 60);
        if ($minutes < 2) {
                return "$seconds sekundoj";
        }

        my ($hours) = int($minutes / 60);
        if ($hours < 2) {
                return "$minutes minutoj";
        }

        my ($days) = int($hours / 24);
        if ($days < 2) {
                return "$hours horoj";
        }

        my ($weeks) = int($days / 7);
        if ($weeks < 2) {
                return "$days tagoj";
        }

        my ($months) = int($days / (365.25 / 12));
        if ($months < 2) {
                return "$weeks semajnoj";
        }

        my ($years) = int($days / 365.25);
        if ($years < 2) {
                return "$months monatoj";
        }

        return "$years jaroj";
}

sub max
{
        my (@args) = @_;
        my ($highest) = shift(@args);
        foreach my $arg (@args) {
                if ($highest < $arg) {
                        $highest = $arg;
                }
        }
        return $highest;
}

# Constants and functions which can be used inside the .mnemo files:
# ==================================================================

BEGIN {
        $CURRENT_FILE_FORMAT_VERSION = '4';
	$MINUTO = $MINUTE = 60;
	$HORO = $HOUR = 60 * $MINUTO;
	$TAGO = $DAY = 24 * $HORO;
        $SEMAJNO = $WEEK = 7 * $TAGO;
	$JARO = $YEAR = 365.25 * $TAGO;
	$MONATO = $MONTH = $JARO / 12;
}

1;      # return a true value.

