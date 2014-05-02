#!/usr/local/bin/perl -w

use English;
use File::Remove 'remove';
use File::Slurp;
use File::Slurp qw(slurp);
use Switch;    # allows the use of switch() structures
use strict;
use Tk;
use Tk::widgets qw(DirSelect LabFrame Widget Dialog);
require('/media/RAID/Video/video_scripts/mvid.pl');
require "BName.pm";
require "VD.pm";

use constant { MKV => ".mkv" };

# Subtitle Toplevel
my ($tlSubtitle);

# Audio & Subtitle Toplevel
my ($tlASS);
my ($bn) = BName->new;
my ($VD) = VD->new;

my (@buttons) = (
    'Audio & Subtitles',
    'Audio Only',
    'Subtitles Only',
    'Chapters & Attachments',
    'Title',
    'Extract Subs'
);

# Main Window
my ($mw) = new MainWindow;
$mw->geometry("330x300");
$mw->title("Main Menu");
$mw->resizable( 0, 0 );    #don't allow resize

# Frame for subframes of main window

my ($lbfrmMainWindow) = $mw->LabFrame(
    -label =>
      'Option                                      Description           ',
    -labelside => 'top'
)->pack;

# Main Window Frames
my ($frmConvert)  = $lbfrmMainWindow->Frame->pack;    #Convert frame
my ($frmEdit)     = $lbfrmMainWindow->Frame->pack;    #Edit frame
my ($frmSubtitle) = $lbfrmMainWindow->Frame->pack;    #Subtitle frame
my ($frmInfo)     = $lbfrmMainWindow->Frame->pack;    #Info frame
my ($frmRename)   = $lbfrmMainWindow->Frame->pack;    #Rename frame
my ($frmFoEpLi)   = $lbfrmMainWindow->Frame->pack;    #FoEpLi frame
my ($frmDelete)   = $lbfrmMainWindow->Frame->pack;    #Delete frame

# Main Menu Labels
my ($lblConvert) = $frmConvert->Label(
    -width => 30,
    -text  => "Convert files in dir to .mkv\t\t"
)->pack( -side => 'right' );
my ($lblEdit) =
  $frmEdit->Label( -width => 30, -text => "Remove Tracks and Fix Titles\t" )
  ->pack( -side => 'right' );
my ($lblSubtitles) = $frmSubtitle->Label(
    -width => 30,
    -text  => "Insert Subtitles into .mkv\t\t"
)->pack( -side => 'right' );
my ($lblInfo) =
  $frmInfo->Label( -width => 30, -text => "Get info for each file in dir\t\t" )
  ->pack( -side => 'right' );
my ($lblRename) =
  $frmRename->Label( -width => 30, -text => "Rename each file in dir\t\t" )
  ->pack( -side => 'right' );
my ($lblFoEpLi) =
  $frmFoEpLi->Label( -width => 30, -text => "Format Episode List\t\t" )
  ->pack( -side => 'right' );
my ($lblDelete) =
  $frmDelete->Label( -width => 30, -text => "Delete tmp video files\t\t" )
  ->pack( -side => 'right' );

# Main Menu Buttons
my ($btnConvert) = $frmConvert->Button(
    -width   => 10,
    -text    => "Convert",
    -command => sub { mainMenu(1); }
)->pack( -side => 'left' );
my ($btnEdit) = $frmEdit->Button(
    -width   => 10,
    -text    => "Edit",
    -command => sub { mainMenu(2); }
)->pack( -side => 'left' );
my ($btnSubtitles) = $frmSubtitle->Button(
    -width   => 10,
    -text    => "Subtitles",
    -command => sub { mainMenu(3); }
)->pack( -side => 'left' );
my ($btnInfo) = $frmInfo->Button(
    -width   => 10,
    -text    => "Info",
    -command => sub { mainMenu(4); }
)->pack( -side => 'left' );
my ($btnRename) = $frmRename->Button(
    -width   => 10,
    -text    => "Rename",
    -command => sub { mainMenu(5); }
)->pack( -side => 'left' );
my ($btnFoEpLi) = $frmFoEpLi->Button(
    -width   => 10,
    -text    => "FoEpLi",
    -command => sub { FTF->FoEpLi($mw); }
)->pack( -side => 'left' );
my ($btnDelete) = $frmDelete->Button(
    -width   => 10,
    -text    => "Delete",
    -command => sub { subVideoDelete(); }
)->pack( -side => 'left' );

MainLoop;

##### GUI Functions #####

# gui for MFix
sub guiMFix {
    my ($selected) =
      $mw->Dialog( -title => "FIX", -buttons => [@buttons] )->Show;
    switch ($selected) {
        case 'Audio & Subtitles'      { guiASS(1); }
        case 'Audio Only'             { guiASS(2); }
        case 'Subtitles Only'         { guiASS(3); }
        case 'Chapters & Attachments' { FixChapAtt(1); }
        case 'Title'                  { FixChapAtt(2); }
        case 'Extract Subs'           { extractSubs(); }
    }
}

#Audio/Subtitle Select
#COMPLETED
sub guiASS {
    my ($assValue) = shift;
    if ( !Exists($tlASS) ) {
        $tlASS = $mw->Toplevel;
        $tlASS->geometry("200x170");
        $tlASS->resizable( 0, 0 );    #don't allow resize
        $tlASS->title('Aud/Sub Select');

        # Frame for subframes of main window
        my ($lbfrmAudio) =
          $tlASS->LabFrame( -label => 'KEEP AUDIO ID#', -labelside => 'top' )
          ->pack;
        my ($lblSeperator)  = $tlASS->Label->pack;
        my ($lbfrmSubtitle) = $tlASS->LabFrame(
            -label     => 'KEEP SUBTITLE ID#',
            -labelside => 'top'
        )->pack;
        my ($lblSeperator2) = $tlASS->Label->pack;

        # MkvFix Window Frames
        my ($frmFixAudio) = $lbfrmAudio->Frame->pack;  #Audio and Subtitle frame
        my ($frmFixSubtitle) = $lbfrmSubtitle->Frame->pack;    #Audio Only frame
        my $entAudio = $frmFixAudio->Entry(
            -background         => 'white',
            -disabledbackground => 'grey'
        )->pack;
        my $entSubtitle = $frmFixSubtitle->Entry(
            -background         => 'white',
            -disabledbackground => 'grey'
        )->pack;
        switch ($assValue) {
            case 1 {
                $entAudio->configure( -state => 'normal' );
                $entSubtitle->configure( -state => 'normal' );
            }

            case 2 {
                $entAudio->configure( -state => 'normal' );
                $entSubtitle->configure( -state => 'disabled' );
            }

            case 3 {
                $entAudio->configure( -state => 'disabled' );
                $entSubtitle->configure( -state => 'normal' );
            }
        }
        my ($btnGO) = $tlASS->Button(
            -width   => 5,
            -text    => "GO",
            -command => sub {
                FixAudSub( $assValue, $entAudio->get(), $entSubtitle->get() );
            }
        )->pack( -side => 'left' );
    }
    else {
        $tlASS->deiconify;
        $tlASS->raise;
    }
}

# Subtitle File Selection
#COMPLETED
sub guiSub {
    if ( !Exists($tlSubtitle) ) {
        $tlSubtitle = $mw->Toplevel;
        $tlSubtitle->geometry("50x200");
        $tlSubtitle->title('');
        $tlSubtitle->resizable( 0, 0 );    #don't allow resize
        $tlSubtitle->Label( -text => 'SBTL' )->pack;
        $tlSubtitle->Button(
            -text    => '.srt',
            -command => sub { mf_SubInstall(".srt") }
        )->pack;
        $tlSubtitle->Button(
            -text    => '.sub',
            -command => sub { mf_SubInstall(".sub") }
        )->pack;
        $tlSubtitle->Button(
            -text    => '.idx',
            -command => sub { mf_SubInstall(".idx") }
        )->pack;
        $tlSubtitle->Button(
            -text    => '.ssa',
            -command => sub { mf_SubInstall(".ssa") }
        )->pack;
        $tlSubtitle->Label( -text => '' )->pack;
        $tlSubtitle->Button(
            -text    => 'Close',
            -command => sub { $tlSubtitle->withdraw }
        )->pack;
    }
    else {
        $tlSubtitle->deiconify;
        $tlSubtitle->raise;
    }
}

###############
#Main Menu
sub mainMenu {
    my $mmArgs = shift;
    my ($strDirectory) =
      $mw->DirSelect( -title => 'Video Directory' )->Show("/media/RAID/Video");
    $VD->set($strDirectory);
    if ($strDirectory) {
        chdir($strDirectory);
        switch ($mmArgs) {
            case 1 { mf_ConvertMKV(); }
            case 2 { guiMFix(); }
            case 3 { guiSub(); }
            case 4 { mf_Info(); }
            case 5 { FTF->AniRename( $strDirectory, $mw ); }
        }
    }
    else { print "No Directory Selected\n\n"; }
}

#Convert to .MKV
sub mf_ConvertMKV {
    my (@files) = read_dir( $VD->get );
     foreach my $file (@files) {
        $bn->set($file);
        my ($fileMKV) = $bn->name() . MKV;
        if ( $bn->suffix() ne MKV ) {
            system( "mkvmerge", "--compression", "1:none","-o", "$fileMKV", "$_" );
            print "\n\n";
            mvid->Movin($file);
        }
    }
}

#Convert to .MKV
sub extractSubs {
    my (@files) = read_dir( $VD->get );
    foreach my $file (@files) {
        $bn->set($file);
        if ( $bn->suffix() eq MKV ) {
            system(
                "mkvextract", "tracks",
                "$file",      "4:" . $bn->name() . ".srt"
            );
            print "\n\n";
        }
    }
}

#Audio Subtitle Fix
#COMPLETED
sub FixAudSub {
    if ( Exists($tlASS) ) { $tlASS->withdraw; }
    my ( $assValue, $valAudioTrack, $valSubtitleTrack ) = @_;
    my (@files) = read_dir( $VD->get() );
   
    #my($valAudioTrack) = $entAudio->get();
    #my($valSubtitleTrack) = $entSubtitle->get();
    foreach my $file (@files) {
        $bn->set($file);
        my ($newName) = $bn->name() . "zz" . $bn->suffix();
        switch ($assValue) {
            case 1 {
                system(
                    "mkvmerge",          "-o",
                    "$newName",          "--audio-tracks",
                    "$valAudioTrack",    "--subtitle-tracks",
                    "$valSubtitleTrack", "$file"
                );
            }
            case 2 {
                system(
                    "mkvmerge",       "-o",             "$newName",
                    "--audio-tracks", "$valAudioTrack", "$file"
                );
            }
            case 3 {
                system(
                    "mkvmerge",          "-o",
                    "$newName",          "--subtitle-tracks",
                    "$valSubtitleTrack", "$file"
                );
            }
        }

        mvid->Movin($file);
        unless ( rename( $file, $newName ) )    #make it rename or die
        {
            print "Rename Failed\n";
        }
        print "\n";
    }
}

sub FixChapAtt {
    if ( Exists($tlASS) ) { $tlASS->withdraw; }
    my ($assValue) = shift;
    my (@files)    = read_dir( $VD->get() );
    foreach (@files) {
        $bn->set($_);
        my ($newName) = $bn->name() . "zz.mkv";
        switch ($assValue) {
            case 1 {
                system(
                    "mkvmerge",      "-o",              "$newName",
                    "--no-chapters", "--no-attchments", "$_"
                );
            }
            case 2 {
                system( "mkvmerge", "-o", "$newName", "--title", $bn->name(),
                    "$_" );
            }
        }
       
        mvid->Movin($_);
        unless ( ! rename( $_, $newName ) ) { print "Rename Failed\n"; }
        print "\n";
    }
}

#Subtitle Install

sub mf_SubInstall {

    # close guiSub
    $tlSubtitle->withdraw;
    my ($valARGS) = shift;
    my (@files)   = read_dir( $VD->get() );
    foreach my $file (@files) {
        $bn->set($file);
        if ( $bn->suffix() ne MKV ) {
            system( "mkvmerge", "-o", $bn->name() . MKV,
                "$file", $bn->name() . "$valARGS" );
            mvid->Movin($file);
        }
        else {
            system( "mkvmerge", "-o", $bn->name() . "zz.mkv",
                "$file", $bn->name() . "$valARGS" );
            mvid->Movin($file);
            unless ( !rename( $file, $bn->name() . "zz.mkv" ) ) {
                print "Rename failed\n";
            }
        }
        print "\n";
    }
}

sub mf_Info(@) {
    my ($strDirectory) = $VD->get;
    open INFO, "| find '$strDirectory' -name '*.mkv' -print | avinfo -l- --html-list -o=/media/RAID/Video/video_scripts/avilist.html"
      or die "Error Opening Pipe or with commands\n";
    close INFO or die "Failed to close pipe";
    
    print "\nDone\n";
}
