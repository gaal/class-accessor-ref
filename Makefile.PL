use ExtUtils::MakeMaker;

require 5.00502;

WriteMakefile(
    NAME                => 'Class::Accessor::Ref',
    VERSION_FROM        => 'lib/Class/Accessor/Ref.pm',
    PREREQ_PM           => { 'Class::Accessor' => '0.10', },
);
