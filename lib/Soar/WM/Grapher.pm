package Soar::WM::Grapher;
# ABSTRACT: Utility for creating graphs of Soar's working memory
use strict;
use warnings;
use Carp;
use Soar::WM qw(wm_root_from_file);
use GraphViz;
use base qw(Exporter);
our @EXPORT_OK = qw(get_graph);

# VERSION

print get_graph(@ARGV)->as_dot unless caller;
# get_graph(@ARGV) unless caller;

sub get_graph{
	my ($file, $id, $depth) = @_;
	if(!($file && $id && $depth)){
		carp 'Usage: get_graph(filename, wme_id, depth)';
		return;
	}
	if($depth < 1){
		carp 'depth argument must be 1 or more';
		return;
	}
	
	my $wm = Soar::WM->new(file => $file);
	my $wme = $wm->get_wme($id);
	my $g = GraphViz->new();#edge=>{arrowhead=>'none'}
	
	#begin graph by adding first WME
	$g->add_node($wme->id);
	return _recurse($wme, $depth, $g);
}

#recursively create GraphViz object
sub _recurse {
	my ($wme, $depth, $g) = @_;
	
	#base case: depth is 0
	return if ! $depth;
	$depth--;
	
	#iterate attributes and their values
	for my $att(@{ $wme->atts }){
		for my $val(@{ $wme->vals($att) }){
			if(ref $val eq 'Soar::WM::Element'){
				#add an edge from parent to att value; label edge with att name
				$g->add_edge($wme->id => $val->id, label => $att);
				_recurse($val, $depth, $g);
			}
			else{
				$g->add_edge($wme->id => $val, label => $att)
			}
		}
	}
	return $g;
}

1;

	