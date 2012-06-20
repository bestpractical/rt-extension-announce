use inc::Module::Install;


RTx 'RT-Extension-Announce';
all_from 'lib/RT/Extension/Announce.pm';
readme_from 'lib/RT/Extension/Announce.pm';
license  'gplv2';

sign;
WriteAll;
