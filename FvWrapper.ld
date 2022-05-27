ENTRY(_start);

SECTIONS
{
    _start = 0xBCC00000;
    . = 0xBCC00000;
    .data : {
        *(.data)
    }
}
