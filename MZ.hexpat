// A bad MZ-exe pattern for DOS binaries
// Reference: http://fileformats.archiveteam.org/wiki/MZ

struct MZHeader {
    char magic[2];
    u16 last_page_bytes;
    u16 page_count; // 512 byte ones, even!
    u16 relocation_count;
    u16 header_size; // In 16-byte paragraphs
    u16 min_memory;
    u16 max_memory;
    s16 ss_register_initial_value;
    u16 sp_register_initial_value;
    u16 optional_checksum;
    u16 ip_register_initial_value;
    s16 cs_register_initial_value;
    u16 relocation_table_start_byte;
    u16 optional_overlay_number;
} [[name("MZ header")]];;

struct Relocation {
    u16 offset;
    u16 segment;
};

// MZ files start with a header giving all the important information
// about where the entrypoint is, the initial values of some
// registers, where the entrypoint in the code is, etc...
MZHeader header @ 0x00;

// The relocation table, defined by the header, are just pairs of u16s
Relocation relocation_table[header.relocation_count] @ header.relocation_table_start_byte;

// The code start happens right after the header, and the header_size
// is measured in 16-byte blocks
u16 code_start = 16 * header.header_size;

// The code end is either the end of the page_count (which are 512
// bytes each) or adjusted to match the last page's size if it's not 0
u16 code_end;
if(header.last_page_bytes == 0){
    code_end = 512 * header.page_count;
} else {
    code_end = 512 * (header.page_count - 1) + header.last_page_bytes;
}

// The code segment can be easily computer with the above
u8 code_segment[code_end - code_start] @ code_start;

// The entrypoint is computed by adding the code_start address to the
// offset of the initial code segment (each segment being 16 bytes)
// and the instruction pointer's initial value
u8 entrypoint @ code_start + (16 * header.cs_register_initial_value) + header.ip_register_initial_value;
