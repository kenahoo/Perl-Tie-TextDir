use Module::Build;

my $build = Module::Build->new
  ( module_name => 'Tie::TextDir',
    dist_version_from => 'TextDir.pm',
    pm_files => { 'TextDir.pm' => 'lib/Tie/TextDir.pm' },
    cleanup_files => ['data'],
  );
$build->create_build_script;
