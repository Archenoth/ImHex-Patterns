#include <std/mem.pat>
#include <std/string.pat>

// Just throws "bytes" at the end of a passed-in thing, so you can
// have it output in the pattern data nicer
fn display_size(auto input){
  return std::format("{} bytes", input);
};

// The file header of Cosmo's Cosmic Adventure is made up of an array
// of 8,3 filenames (12 chars is the maximum for DOS), the location
// *in* the file where these files exist, and how many bytes they are
// after you seek to those locations
struct FileRecord {
  // An 8,3 (DOS 8 character, 3-long extension) filename filled with
  // nulls
  char filename[12] [[format("std::string::to_string")]];

  // Where in the archive this file exists, and how long it is!
  u32 fileAddr;
  u32 size [[format("display_size")]];

  // The file itself! Placed
  u8 data[size] @ fileAddr;
};

// Nicely format's a FileRecord's details as a string
fn display_file_info(FileRecord file){
  return std::format("{}: ({} bytes)", file.filename, file.size);
};

FileRecord contents[
  while(std::mem::read_string($, 2) != std::string::to_string($ / 20))
] @ 0x00 [[format_entries("display_file_info")]];

// The number of files in the record are these two bytes, as a string
char file_count[2] @ $;

// Everything from the end of the file count to the beginning of the
// first file in the archive are empty header space (This could be a
// fixed position, but for now, I'm just grabbing the first file's
// address)
u8 empty_header_space[contents[0].fileAddr - $] @ $;

// WIP: An attempt to give the Pattern data output the files on their
// own, outside of the pointers in the header structs. Otherwise
// clicking a random part of the file won't highlight it in the
// pattern editor, and things are out of order
//
// (I still need to figure out how to do this)

//#pragma debug
//for(u8 i = 0, i < std::string::parse_int(file_count, 10), i = i + 1){
//    std::print("{}", contents[i].size);
//    u8 file[1] [[no_unique_address]] @ $;
//};
