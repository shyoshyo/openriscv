SECTIONS
{
	. = 0x80000000;

	.text :
	{
		*(.text)
	}

	.data :
	{
		*(.data)
	}

	.bss :
	{
		*(.bss)
	}

	.stack	ALIGN(0x10) (NOLOAD):
	{
		*(.stack)
		_ram_end = .;
	}
}

ENTRY (_start)
