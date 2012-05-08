use ExtUtils::MakeMaker;

die "OS unsupported\n" unless $^O =~ /linux/;

WriteMakefile(
	NAME          => 'IO::Lambda::Inotify',
	AUTHOR        => 'Dmitry Karasik <dmitry@karasik.eu.org>',
	ABSTRACT_FROM => 'lib/IO/Lambda/Inotify.pm',
	VERSION_FROM  => 'lib/IO/Lambda/Inotify.pm',
	PREREQ_PM     => {
		'Linux::Inotify2'   => 1.21,
		'IO::Lambda'        => 1.22,
	},
);
