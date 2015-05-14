require "test_helper"


# TODO: also test with feature(Cached)

class CachedTest < MiniTest::Spec


  class SongRepresenter < Representable::Decorator
    include Representable::Hash
    include Representable::Cached

    property :title
    property :composer, render_filter: lambda { |value, doc, options| "#{value}: #{options.user_options}" }, pass_options: true
  end

  class AlbumRepresenter < Representable::Decorator
    include Representable::Hash
    include Representable::Cached

    property :name
    collection :songs, decorator: SongRepresenter
  end



  module Model
    Song  = Struct.new(:title, :composer)
    Album = Struct.new(:name, :songs, :artist)
    Artist = Struct.new(:name, :hidden_taste)
  end

  it do


    song  = Model::Song.new("Jailbreak")
    song2 = Model::Song.new("Southbound")
    album = Model::Album.new("Live And Dangerous", [song, song2, Model::Song.new("Emerald")])

    album2 = Model::Album.new("Louder And Even More Dangerous", [song2, song])



    representer = AlbumRepresenter.new(album)




    representer.to_hash(special: "yes!").must_equal( {"name"=>"Live And Dangerous", "songs"=>[{"title"=>"Jailbreak", "composer"=>": {:special=>\"yes!\"}"}, {"title"=>"Southbound", "composer"=>": {:special=>\"yes!\"}"}, {"title"=>"Emerald", "composer"=>": {:special=>\"yes!\"}"}]})



    representer.update!(album2, {better: "yummy"})
    representer.to_hash(hey: "ho!").must_equal( {"name"=>"Live And Dangerous", "songs"=>[{"title"=>"Jailbreak", "composer"=>": {:special=>\"yes!\"}"}, {"title"=>"Southbound", "composer"=>": {:special=>\"yes!\"}"}, {"title"=>"Emerald", "composer"=>": {:special=>\"yes!\"}"}]})


  end

end
# require "pp"
# # puts "???"
# # pp representer

# representer.update!(album2, {})




# puts "???"

# puts representer.to_hash # called in Deserializer/Serializer

# puts ".."
# puts "."

# definition = SongRepresenter.representable_attrs.get(:title)

# binding = Representable::Hash::Binding.build(definition, song, Object)

# puts "++"
# puts "++ #{binding.compile_fragment({})}"

# binding.instance_variable_set(:@represented, song2)
# binding.instance_variable_set(:@exec_context, song2)

# puts "++ #{binding.compile_fragment({})}"

