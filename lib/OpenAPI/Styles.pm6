use v6;
#`(
Copyright © Altai-man altay-man@mail.ru

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

)

unit class OpenAPI::Styles;

our enum Style <Matrix Label Form Simple SpaceDelimited PipeDelimited DeepObject>;

our sub from-openapi-style(Style $style, $string, Bool :$explode!, Str :$name!, :$type!) is export {
    return from-openapi-explode($style, $string, $name, $type) if $explode;
    return from-openapi-non-explode($style, $string, $name, $type) unless $explode;
}

my sub from-openapi-explode($style, $value, $name, $type) {
    given $style {
        when Matrix {
            return Nil if $value eq ";$name";
            return $value.split('=')[1] if $type ~~ Str;
            my @parts = $value.split(';')[1..*];
            return @parts.map({.split('=')[1]}) if $type ~~ Positional;
            return @parts.map({.split('=')}).flat.Hash if $type ~~ Hash;
        }
        when Label {
            return Nil if $value eq '.';
            return $value.split('.')[1] if $type ~~ Str;
            my @parts = $value.split('.')[1..*];
            return @parts if $type ~~ Positional;
            return @parts.map(*.split('=')).flat.Hash if $type ~~ Hash;
        }
        when Form {
            return Nil if $value eq "$name=";
            my $stripped-value = $value.split('=')[1];
            return $stripped-value if $type ~~ Str;
            my @parts = $value.split('&');
            return @parts.map({.split('=')[1]}) if $type ~~ Positional;
            return @parts.map({.split('=')}).flat.Hash if $type ~~ Hash;
        }
        when Simple {
            return $value if $type ~~ Str;
            return $value.split(',') if $type ~~ Positional;
            return $value.split(',').map(*.split('=')).flat.Hash if $type ~~ Hash;
        }
        when SpaceDelimited {
            die 'Cannot use space delimited scheme in explode mode'
        }
        when PipeDelimited {
            die 'Cannot use pipe delimited scheme in explode mode'
        }
        when DeepObject {
            my @parts = $value.split('&');
            return @parts.map({$_ ~~ /'[' $<k>=(\w+) ']=' $<v>=(\w+) /}).map({ $<k>, $<v> }).flat.Hash
        }
    }
    return Nil;
}

my sub from-openapi-non-explode($style, $value, $name, $type) {
    given $style {
        when Matrix {
            return Nil if $value eq ";$name";
            my $stripped-value = $value.split('=')[1];
            return $stripped-value if $type ~~ Str;
            return $stripped-value.split(',') if $type ~~ Positional;
            return $stripped-value.split(',').Hash if $type ~~ Hash;
        }
        when Label {
            return Nil if $value eq '.';
            my $stripped-value = $value.split('.')[1];
            return $stripped-value if $type ~~ Str;
            return $value.split('.')[1..*] if $type ~~ Positional;
            return $value.split('.')[1..*].Hash if $type ~~ Hash;
        }
        when Form {
            return Nil if $value eq "$name=";
            my $stripped-value = $value.split('=')[1];
            return $stripped-value if $type ~~ Str;
            return $stripped-value.split(',') if $type ~~ Positional;
            return $stripped-value.split(',').Hash if $type ~~ Hash;
        }
        when Simple {
            return $value if $type ~~ Str;
            return $value.split(',') if $type ~~ Positional;
            return $value.split(',').Hash if $type ~~ Hash;
        }
        when SpaceDelimited {
            return $value.split('%20') if $type ~~ Positional;
            return $value.split('%20').Hash if $type ~~ Hash;
        }
        when PipeDelimited {
            return $value.split('|') if $type ~~ Positional;
            return $value.split('|').Hash if $type ~~ Hash;
        }
        when DeepObject {
            die 'Cannot use deep object scheme in non-explode mode'
        }
    }
    return Nil;
}

our sub to-openapi-style(Style $style, $value, Bool :$explode!, Str :$name!) is export {
    return to-openapi-explode($style, $value, $name) if $explode;
    return to-openapi-non-explode($style, $value, $name) unless $explode;
}

my sub to-openapi-explode($style, $value, $name) {
    given $style {
        when Matrix {
            if $value ~~ Nil {
                return ";$name"
            } elsif $value ~~ Str {
                return ";$name=$value"
            } elsif $value ~~ Positional {
                return ';' ~ $value.map({ "$name=$_" }).join(';');
            } elsif $value ~~ Hash {
                return ';' ~ $value.map({ .key ~ '=' ~ .value }).join(';');
            }
        }
        when Label {
            if $value ~~ Nil {
                return '.'
            } elsif $value ~~ Str {
                return ".$value"
            } elsif $value ~~ Positional {
                return '.' ~ $value.join('.')
            } elsif $value ~~ Hash {
                return '.' ~ $value.map({ .key ~ '=' ~ .value }).join('.');
            }
        }
        when Form {
            if $value ~~ Nil {
                return "$name="
            } elsif $value ~~ Str {
                return "$name=$value"
            } elsif $value ~~ Positional {
                return $value.map({ "color=$_" }).join('&')
            } elsif $value ~~ Hash {
                return $value.map({ .key ~ '=' ~ .value }).join('&')
            }
        }
        when Simple {
            if $value ~~ Nil {
                die 'Cannot express Nil with Simple style'
            } elsif $value ~~ Str {
                return $value
            } elsif $value ~~ Positional {
                return $value.join(',')
            } elsif $value ~~ Hash {
                return $value.map({ .key ~ '=' ~ .value }).join(',')
            }
        }
        when SpaceDelimited {
            die 'Cannot use space delimited scheme in explode mode'
        }
        when PipeDelimited {
            die 'Cannot use pipe delimited scheme in explode mode'
        }
        when DeepObject {
            if $value ~~ Nil {
                die 'Cannot express Nil with deep object style'
            } elsif $value ~~ Str {
                die 'Cannot express Str with deep object style'
            } elsif $value ~~ Positional {
                die 'Cannot express Positional with deep object style'
            } elsif $value ~~ Hash {
                return $value.map({ "$name\[{.key}\]={.value}" }).join('&')
            }
        }
    }
    return Nil;
}

my sub to-openapi-non-explode($style, $value, $name) {
    given $style {
        when Matrix {
            if $value ~~ Nil {
                return ";$name"
            } elsif $value ~~ Str {
                return ";$name=$value"
            } elsif $value ~~ Positional {
                return ";$name=" ~ $value.join(',')
            } elsif $value ~~ Hash {
                return ";$name=" ~ $value.kv.join(',')
            }
        }
        when Label {
            if $value ~~ Nil {
                return '.'
            } elsif $value ~~ Str {
                return ".$value"
            } elsif $value ~~ Positional {
                return '.' ~ $value.join('.')
            } elsif $value ~~ Hash {
                return '.' ~ $value.kv.join('.')
            }
        }
        when Form {
            if $value ~~ Nil {
                return "$name="
            } elsif $value ~~ Str {
                return "$name=$value"
            } elsif $value ~~ Positional {
                return "$name=" ~ $value.join(',')
            } elsif $value ~~ Hash {
                return "$name=" ~ $value.kv.join(',')
            }
        }
        when Simple {
            if $value ~~ Nil {
                die 'Cannot express Nil with Simple style'
            } elsif $value ~~ Str {
                return $value
            } elsif $value ~~ Positional {
                return $value.join(',')
            } elsif $value ~~ Hash {
                return $value.kv.join(',')
            }
        }
        when SpaceDelimited {
            if $value ~~ Nil {
                die 'Cannot express Nil with space delimited style'
            } elsif $value ~~ Str {
                die 'Cannot express Str with space delimited style'
            } elsif $value ~~ Positional {
                return $value.join('%20')
            } elsif $value ~~ Hash {
                return $value.kv.join('%20')
            }
        }
        when PipeDelimited {
            if $value ~~ Nil {
                die 'Cannot express Nil with pipe delimited style'
            } elsif $value ~~ Str {
                die 'Cannot express Str with pipe delimited style'
            } elsif $value ~~ Positional {
                return $value.join('|')
            } elsif $value ~~ Hash {
                return $value.kv.join('|')
            }
        }
        when DeepObject {
            die 'Cannot use deep object scheme in non-explode mode'
        }
    }
    return Nil;
}

=begin pod

=head1 NAME

OpenAPI::Styles - serialize and deserialize OpenAPI style-formatted values.

=head1 SYNOPSIS

  use OpenAPI::Styles;

=head1 DESCRIPTION

OpenAPI::Styles is a module that provides means to serialize and deserialize between Perl 6 values and OpenAPI supported value string based on particular style.

=head1 AUTHOR


Altai-man altay-man@mail.ru 


=head1 COPYRIGHT AND LICENSE

Copyright © Altai-man altay-man@mail.ru

License GPLv3: The GNU General Public License, Version 3, 29 June 2007
<https://www.gnu.org/licenses/gpl-3.0.txt>

This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.


=end pod
