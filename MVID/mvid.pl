{

    package mvid;
    
    use English;
    use strict;
    use warnings;
    use Number::Bytes::Human qw(format_bytes);
    use File::Slurp qw(slurp);
    use File::Slurp;
    use constant { TXT => "/media/RAID/Video/video_scripts/Storage.txt" };

    sub f_storage {
        my ($class) = shift;
        my (@str)   = @_;            #get array of text
        my (@lines) = slurp(TXT);    # read lines from TXT into array
        write_file( TXT, @str );     # write array into TXT
        append_file( TXT, @lines );  # append array into TXT
    }

    sub g_size {
        my ($class) = shift;
        my @ret;
        foreach (@_) { push( @ret, format_bytes( -s $_ ) ); }
        return @ret;
    }

    sub Movin {
        my ( $class, $valARGS ) = @_;
        system( "mv", "$valARGS", "/media/RAID/Video/Video_Delete/" );
    }
}

{

    package DATE;

    use English;
    use strict;
    use warnings;
    use Date::Formatter;

    sub timestamp {
        my ($date) = Date::Formatter->now();
        $date->createDateFormatter(
            "Date: (M) (DD), (YYYY) Time: (hh):(mm):(ss) (T)");
        return ($date);
    }
}

{

    package FTF;

    use English;
    use strict;
    use warnings;
    use File::Basename;
    use File::Slurp qw(slurp);
    use File::Slurp;
    use Tk;
    use Tk::widgets qw(Widget Dialog);
    require "BName.pm";
    use constant { EPISODES => "/media/RAID/Video/video_scripts/Episodes" };

    my ($bn) = BName->new;

    #Format Episode List
    sub FoEpLi {
        my ( $class, $mw ) = @_;
        my (@epIndex);
        foreach ( grep( /^[0-9]/, slurp(EPISODES) ) )
        {    #foreach (grep starts with num, read file line per line)
            my ($tempin) =
              substr( $_, index( $_, "." ) + 1 )
              ;    #remove everything in front up to and including first '.'
            $tempin =~ s/^\s+//;    #remove whitespace from begining
            push( @epIndex, $tempin );
        }
        write_file( EPISODES, @epIndex );
        $mw->messageBox( -message => "Format Complete", -type => "ok" );
    }

    # Rename files in the directory
    sub AniRename {
        my ( $class, $path, $mw ) = @_;
        my ($tlRename) = $mw->Toplevel;

        $tlRename->title('AniRename');
        $tlRename->Label( -text => 'Original Filename -> New Filename' )->pack;

        #Text Area
        my ($txt) = $tlRename->Text( -width => 200, -height => 50 )->pack();

        my (@dir) = read_dir($path);    #read list of files from directory
        chomp( my (@ep) = slurp(EPISODES) );   #read file line per line into @ep and remove the newline character
        foreach my $file (@dir) {
            $bn->set($file);
            my ($num) = substr( $bn->name, -2 );
            ( $num-- );
            my ($newName) = $bn->name . " - $ep[$num]" . $bn->suffix;
            print $newName . "\n";
            if ( rename( $file, $newName ) ) {
                $txt->insert( 'end',
                    "\n" . $bn->name . " -> " . $bn->name . " - $ep[$num]\n" );
            }
            else { $txt->insert( 'end', "\nFailed to rename file $file\n" ); }
        }
    }

}
1;
