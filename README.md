# Summary

ContextAwareDataflow is a domain-specific language for building context-
aware mobile apps. It is a library based on the bloom-bud extension
of Ruby, developed by several Ph.D. students from UC Berkeley.

See LICENSE for licensing information.

ContextAwareDataflow is developed by Kasturi Raghavan and Chenguang Shen
as the course project of CS 239 Winter 2013 at UCLA. For any questions,
contact Kasturi (kr@cs.ucla.edu) or Chenguang (cgshen@cs.ucla.edu).

# Installation

To use the ContextAwareDataflow extension, you need to have Ruby installed
on your computer. Our code is tested under Mac OS X 10.8.2, and should
be working with Linux. The Ruby version we have is 1.8.7. We cannot
ensure the code would still work under other versions of Ruby.

You could generally follow these steps to used the ContextAwareDataflow
library:

## Install dependent gems:
	
	% gem install backports

	% gem install docile
	
	% gem install eventmachine
	
	% gem install msgpack
	
	% gem install slop

## Modify Ruby's gem path

Since we haved modified the original bud runtime, you could not install
the bud gem directly. Instead, you will have to put Gems/ folder in your
Ruby's gem path and use our modified bud inside. To do this, just
modify the .gemrc file, and put the path to OUR Gems/ folder in both
gemhome and gempath. In addition, don't forget to include your systems'
default Ruby gem path (in Mac OS X, this is usually /Library/Ruby/Gems/1.8)
in gempath. After the previous modification, put the .gemrc file under
your home folder.

	% cp .gemrc ~/

Next, you need to also include GEM_HOME and GEM_PATH as environment
variables (assume you are using bash). Remember to keep the original
gem path in GEM_PATH so that you can still use other Ruby gems.

	% echo export GEM_HOME=/path/to/our/lib/Gems >> ~/.bashrc

	% echo export GEM_PATH=/path/to/our/lib/Gems:/path/to/your/original/gem/folder >> ~/.bashrc

	% source ~/.bashrc

If you run
	
	% gem env

you should be able to see our Gems/ folder included in both gemhome and gempath.

# Run Test Code

