package Class::Accessor::Ref;

use strict;
use vars qw($VERSION);
$VERSION = '0.01';
use base 'Class::Accessor';

=pod

=head1 NAME

Class::Accessor::Ref - Access members by reference

=head1 SYNOPSIS

  package Foo;
  use base qw(Class::Accessor::Ref);
  use Some::API;

  my @members = qw(fruit color);
  Foo->mk_accessors(@members);     # as with Class::Accessor
  Foo->mk_refaccessors(@members);

  my $obj = Foo->new({fruit => 'grape', color => 'green'});
  Some::API::redden($obj->_ref_color);
  print $obj->color;               # prints 'red'

=head1 DESCRIPTION

This is an extension of Class::Accessor that allows taking a reference
of members of an object. This is typically useful when your class
implementation uses a third-party module that expect an in/out parameter
in its interface.

Without Class::Accessor::Ref, you might try to do somethin like

  my $reference = \$obj->member;   # WRONG!
  Some::API::call($reference);

But that takes a reference to a B<copy> of $obj->member, and is thus
not useful if you want to use the reference to later change the member's
value.

It is quite possible to do something like

  my $reference = \$obj->{member}; # right, but risky

But then you will get no errors if you accidentally mistype the member's
name.

Class::Accessor::Ref is used very similarly to Class::Accessor --
just subclass it instead of Class::Accessor in your module, and call
mk_accessors on the fields you want to generate accessors for. Then, call
mk_refaccessors on the subset of the fields you want reference-taking
accessors generated for. The accessors will be automatically named
_ref_FIELD. You can continue to use the normal (non-reference) accessors
as before whenever appropriate.


=cut

my $ref_accessor = sub {
    my($self, $field) = @_;
    return \$self->{$field};
};

sub mk_refaccessors {
    my($class, @fields) = @_;
    no strict 'refs';
    for my $field (@fields) {
        die "$field is not a valid field" unless $class->can($field);
        *{"${class}::_ref_$field"} = sub { $ref_accessor->($_[0], $field) };
    }
}


=pod

=head2 Methods

=over 4

=item B<mk_refaccessor>

    Class->mk_refaccessors(@fields);

This creates accessor methods for each named field given in @fields.
Foreach field in @fields it will generate one accessor called
"_ref_field()".  Normal accessors for the fields *must* have already
been created with Class::Accessor::mk_accessors(). For example:

    # Generates _ref_foo(), _ref_bar() but not _ref_baz():
    #     Class->mk_accessors(qw(foo bar baz));
    #     Class->mk_refaccessors(qw(foo bar));

It is up to the user of this reference to know what to do with it.

=back

=head1 CAVEATS

Class::Accessor::Ref generates methods called _ref_SOMETHING in the
caller's namespace. Having an existing member whose name begins with
_ref_ would render the normal accessor to that member inaccessible,
so don't do that.

One point of Class::Accessor is to allow you to avoid changing members
directly. Since whoever gets hold of the return value of a _ref_ accessor
can circumvent any validations you may have imposed on the member (for
example, by overriding the normal setter method), this can be considered
somewhat unsafe. The main use of Class::Accessor::Ref is inside class
implementations, where you have control over who you trust with giving
a reference to your private data and who you don't.

=head1 AUTHOR

Gaal Yahas <gaal@forum2.org>


=head1 SEE ALSO

L<Class::Accessor>

=cut


1;
