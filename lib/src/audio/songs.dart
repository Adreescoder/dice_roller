const Set<Song> songs = {};

class Song {
  const Song(this.filename, this.name, {this.artist});

  final String filename;
  final String name;
  final String? artist;

  @override
  String toString() => 'Song<$filename>';
}
