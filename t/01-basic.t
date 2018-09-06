use v6;

use Test;
use OpenAPI::Styles;

my $string = "blue";
my $array = <blue black brown>;
my $object = { R => 100, G => 200, B => 150 };

# ========== Deserializing part
given OpenAPI::Styles::Matrix {
    # We use Rat here, because for empty case we are checking that algorithm completely ignores type sent
    is from-openapi-style($_, ';color', :!explode, :name('color'), :type(Rat)), Nil;
    is from-openapi-style($_, ';color', :explode,  :name('color'), :type(Rat)), Nil;

    is from-openapi-style($_, ';color=blue', :!explode, :name('color'), :type(Str)), $string;
    is from-openapi-style($_, ';color=blue', :explode,  :name('color'), :type(Str)), $string;

    is from-openapi-style($_, 'color=blue,black,brown',              :!explode, :name('color'), :type(Positional)), $array;
    is from-openapi-style($_, ';color=blue;color=black;color=brown', :explode,  :name('color'), :type(Positional)), $array;

    is from-openapi-style($_, ';color=R,100,G,200,B,150', :!explode, :name('color'), :type(Hash)), $object;
    is from-openapi-style($_, ';R=100;G=200;B=150',       :explode,  :name('color'), :type(Hash)), $object;
}

given OpenAPI::Styles::Label {
    # We use Rat here, because for empty case we are checking that algorithm completely ignores type sent
    is from-openapi-style($_, '.', :!explode, :name('color'), :type(Rat)), Nil;
    is from-openapi-style($_, '.', :explode,  :name('color'), :type(Rat)), Nil;

    is from-openapi-style($_, '.blue', :!explode, :name('color'), :type(Str)), $string;
    is from-openapi-style($_, '.blue', :explode,  :name('color'), :type(Str)), $string;

    is from-openapi-style($_, '.blue.black.brown', :!explode, :name('color'), :type(Positional)), $array;
    is from-openapi-style($_, '.blue.black.brown', :explode,  :name('color'), :type(Positional)), $array;

    is from-openapi-style($_, '.R.100.G.200.B.150', :!explode, :name('color'), :type(Hash)), $object;
    is from-openapi-style($_, '.R=100.G=200.B=150', :explode,  :name('color'), :type(Hash)), $object;
}

given OpenAPI::Styles::Form {
    # We use Rat here, because for empty case we are checking that algorithm completely ignores type sent
    is from-openapi-style($_, 'color=', :!explode, :name('color'), :type(Rat)), Nil;
    is from-openapi-style($_, 'color=', :explode,  :name('color'), :type(Rat)), Nil;

    is from-openapi-style($_, 'color=blue', :!explode, :name('color'), :type(Str)), $string;
    is from-openapi-style($_, 'color=blue', :explode,  :name('color'), :type(Str)), $string;

    is from-openapi-style($_, 'color=blue,black,brown', :!explode, :name('color'), :type(Positional)), $array;
    is from-openapi-style($_, 'color=blue&color=black&color=brown', :explode,  :name('color'), :type(Positional)), $array;

    is from-openapi-style($_, 'color=R,100,G,200,B,150', :!explode, :name('color'), :type(Hash)), $object;
    is from-openapi-style($_, 'R=100&G=200&B=150', :explode,  :name('color'), :type(Hash)), $object;
}

given OpenAPI::Styles::Simple {
    is from-openapi-style($_, 'blue', :!explode, :name('color'), :type(Str)), $string;
    is from-openapi-style($_, 'blue', :explode,  :name('color'), :type(Str)), $string;

    is from-openapi-style($_, 'blue,black,brown', :!explode, :name('color'), :type(Positional)), $array;
    is from-openapi-style($_, 'blue,black,brown', :explode,  :name('color'), :type(Positional)), $array;

    is from-openapi-style($_, 'R,100,G,200,B,150', :!explode, :name('color'), :type(Hash)), $object;
    is from-openapi-style($_, 'R=100,G=200,B=150', :explode,  :name('color'), :type(Hash)), $object;
}

given OpenAPI::Styles::SpaceDelimited {
    is from-openapi-style($_, 'blue%20black%20brown', :!explode, :name('color'), :type(Positional)), $array;

    is from-openapi-style($_, 'R%20100%20G%20200%20B%20150', :!explode, :name('color'), :type(Hash)), $object;
}

given OpenAPI::Styles::PipeDelimited {
    is from-openapi-style($_, 'blue|black|brown', :!explode, :name('color'), :type(Positional)), $array;

    is from-openapi-style($_, 'R|100|G|200|B|150', :!explode, :name('color'), :type(Hash)), $object;
}

given OpenAPI::Styles::DeepObject {
    is from-openapi-style($_, 'color[R]=100&color[G]=200&color[B]=150', :explode,  :name('color'), :type(Hash)), $object;
}


# ========== Serializing part
given OpenAPI::Styles::Matrix {
    # We use Rat here, because for empty case we are checking that algorithm completely ignores type sent
    is to-openapi-style($_, Nil, :!explode, :name('color')), ';color';
    is to-openapi-style($_, Nil, :explode,  :name('color')), ';color';

    is to-openapi-style($_, $string, :!explode, :name('color')), ';color=blue';
    is to-openapi-style($_, $string, :explode,  :name('color')), ';color=blue';

    is to-openapi-style($_, $array, :!explode, :name('color')), ';color=blue,black,brown';
    is to-openapi-style($_, $array, :explode,  :name('color')), ';color=blue;color=black;color=brown';
}

given OpenAPI::Styles::Label {
    # We use Rat here, because for empty case we are checking that algorithm completely ignores type sent
    is to-openapi-style($_, Nil, :!explode, :name('color')), '.';
    is to-openapi-style($_, Nil, :explode,  :name('color')), '.';

    is to-openapi-style($_, $string, :!explode, :name('color')), '.blue';
    is to-openapi-style($_, $string, :explode,  :name('color')), '.blue';

    is to-openapi-style($_, $array, :!explode, :name('color')), '.blue.black.brown';
    is to-openapi-style($_, $array, :explode,  :name('color')), '.blue.black.brown';
}

given OpenAPI::Styles::Form {
    # We use Rat here, because for empty case we are checking that algorithm completely ignores type sent
    is to-openapi-style($_, Nil, :!explode, :name('color')), 'color=';
    is to-openapi-style($_, Nil, :explode,  :name('color')), 'color=';

    is to-openapi-style($_, $string, :!explode, :name('color')), 'color=blue';
    is to-openapi-style($_, $string, :explode,  :name('color')), 'color=blue';

    is to-openapi-style($_, $array, :!explode, :name('color')), 'color=blue,black,brown';
    is to-openapi-style($_, $array, :explode,  :name('color')), 'color=blue&color=black&color=brown';
}

given OpenAPI::Styles::Simple {
    is to-openapi-style($_, $string, :!explode, :name('color')), 'blue';
    is to-openapi-style($_, $string, :explode,  :name('color')), 'blue';

    is to-openapi-style($_, $array, :!explode, :name('color')), 'blue,black,brown';
    is to-openapi-style($_, $array, :explode,  :name('color')), 'blue,black,brown';
}

given OpenAPI::Styles::SpaceDelimited {
    is to-openapi-style($_, $array, :!explode, :name('color')), 'blue%20black%20brown';
}

given OpenAPI::Styles::PipeDelimited {
    is to-openapi-style($_, $array, :!explode, :name('color')), 'blue|black|brown';
}

done-testing;
