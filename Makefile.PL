use inc::Module::Install;
requires 'Mail::SpamAssassin';
RTx('RT-Extension-SpamAssassin');
all_from('lib/RT/Extension/SpamAssassin.pm');
readme_from('lib/RT/Extension/SpamAssassin.pm');
&WriteAll;
