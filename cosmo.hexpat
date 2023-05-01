#include <std/mem.pat>
#include <std/string.pat>

//// Functions for FileRecord struct

// Removes the trailing \0 from fixed-buffer but NUL-filled strings
// (Like the file titles in this case!)
fn trim_nul_from_string(str input){
  return std::string::replace(input, "\\0", "");
};

// Just throws "bytes" at the end of a passed-in thing, so you can
// have it output in the pattern data nicer
fn display_size(auto input){
  return std::format("{} bytes", input);
};

// Gets around the inability (AFAICT) to reference bytes defined later
// in structs by getting the address of the current struct and adding
// the sizeof(filename[12]) and the file pointer
//
// $ still refers to 0 since this is in the definition of the struct
// before "placing" it, as do all mem functions that deal with the
// current address, but wrapping this in a function defers this until
// the address can be resolved
//
// Also, as mentioned earlier, saying this.size won't work either
// since it is defined as the next member, so it doesn't recognize it
// like this.filename would be
//
// There may be a better way to do this, but I'm not sure how
fn get_filesize_addr(){
  return addressof(parent) + 16;
};

// The file header of Cosmo's Cosmic Adventure is made up of an array
// of 8,3 filenames (12 chars is the maximum for DOS), the location
// *in* the file where these files exist, and how many bytes they are
// after you seek to those locations
struct FileRecord {
  char filename[12] [[format("trim_nul_from_string")]];
  u8 *file[std::mem::read_unsigned(get_filesize_addr(), 4)] : u32 [[inline]];
  u32 size [[format("display_size")]];
};


//// Functions for contents[] definition

// Nicely format's a FileRecord's details as a string
fn display_file_info(FileRecord file){
  return std::format("{}: ({} bytes)", file.filename, file.size);
};

// The FileRecords at the beginning of the Cosmo archives end when the
// next characters read are the nubmer of files in the archive rather
// than another file record
FileRecord contents[
    while(std::mem::read_string($, 2) != std::string::to_string($ / sizeof(FileRecord)))
] @ 0x00 [[format_entries("display_file_info")]];

// The number of files in the record are these two bytes
char file_count[2] @ $;

// Everything from the end of the file count to the beginning of the
// first file in the archive are empty header space (This could be a
// fixed position, but for now, I'm just grabbing the first file's
// address)
u8 empty_header_space[addressof(contents[0].file) - $] @ $;

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
