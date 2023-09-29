package Aion::Spirit;
use 5.22.0;
no strict; no warnings; no diagnostics;
use common::sense;

our $VERSION = "0.0.0-prealpha";

require Exporter;
our @EXPORT = our @EXPORT_OK = grep {
	*{$Aion::Spirit::{$_}}{CODE} && !/^(_|(NaN|import)\z)/n
} keys %Aion::Spirit::;

#@category Аспект-ориентированное программирование

# Оборачивает функции в пакете в указанную по регулярке. 
# Имя функции идёт вместе с пакетом
sub aroundsub($$;$) {
	my ($pkg, $re, $around) = @_==3? @_: ((caller)[0], @_);
	my $x = \%{"${pkg}::"};
	
	require Sub::Util;
	
	for my $g (values %$x) {
		my $sub = *{$g}{CODE} or next;
		
		if(Sub::Util::subname($sub) =~ $re) {
			*$g = wrapsub($sub => $around);
		}
	}
}

# Оборачивает функцию в другую
sub wrapsub($$) {
	my ($sub, $around) = @_;
	
	
	my $s = (sub {
		my ($around, $sub) = @_;
		sub { unshift @_, $sub; goto &$around }
	})->($around, $sub);
	
	my $subname = Sub::Util::subname $sub;
	#p $subname;
	Sub::Util::set_subname "${subname}__AROUND__" =>
	Sub::Util::set_prototype Sub::Util::prototype($sub) => $s;
	
	$s
}

#@category Проверки

# assert
sub ASSERT {
	die "ASSERT: ".(ref $_[1]? $_[1]->(): $_[1])."\n" if !$_[0];
}

#@category Списки

# Ищет в списке первое совпадение и возвращает индекс найденного элемента
sub firstidx (&@) {
	my $s = shift;

	my $i = 0;
	for(@_) {
		return $i if $s->();
		$i++;
	}
	return undef;
}

# Ищет в списке первый положительный разультат функции
sub firstres (&@) {
	my $s = shift;

	for(@_) {
		my $x = $s->();
		return $x if $x;
	}
	return undef;
}

1;
