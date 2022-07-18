meta:
  id: isobmff
  application: ISO base media file
  file-extension:
    - mp4
    - mov
    - aac
    - fmp4
  endian: be
  xref:
    iso: '14496-12:2022'
doc-ref: https://www.iso.org/standard/83102.html

seq:
  - id: boxes
    type: box
    repeat: eos

types:

  box:
    seq:
      - id: size
        type: u4
      - id: boxtype
        type: u4
        enum: boxtype
      - id: largesize
        type: u8
        if: size == 1
      - id: data
        size: len
        type:
          switch-on: boxtype
          cases:
            boxtype::uuid: uuid
            boxtype::ftyp: general_type_box
            boxtype::moov: box_container
            boxtype::mvhd: movie_header_box
            boxtype::meta: fullbox
            boxtype::trak: box_container
            boxtype::tkhd: track_header_box
            boxtype::tref: box_container
            boxtype::trgr: box_container
            boxtype::edts: box_container
            boxtype::elst: edit_list_box
            boxtype::mdia: box_container
            boxtype::mdhd: media_header_box
            boxtype::hdlr: handler_reference_box
            boxtype::elng: fullbox
            boxtype::minf: box_container
            boxtype::vmhd: video_media_header_box
            boxtype::smhd: fullbox
            boxtype::hmhd: fullbox
            boxtype::sthd: box_container
            boxtype::nmhd: box_container
            boxtype::dinf: box_container
            boxtype::dref: data_reference_box
            boxtype::url : data_entry_url_box
            boxtype::urn : data_entry_urn_box
            boxtype::imdt: data_entry_imda_box
            boxtype::snim: fullbox
            boxtype::stbl: box_container
            boxtype::stsd: sample_description_box
            boxtype::stts: time_to_sample_box
            boxtype::ctts: fullbox
            boxtype::cslg: fullbox
            boxtype::stsc: sample_to_chunk_box
            boxtype::stsz: sample_size_box
            boxtype::stz2: fullbox
            boxtype::stco: fullbox
            boxtype::co64: fullbox
            boxtype::stss: fullbox
            boxtype::stsh: fullbox
            boxtype::padb: fullbox
            boxtype::stdp: fullbox
            boxtype::sdtp: fullbox
            boxtype::sbgp: fullbox
            boxtype::sgpd: fullbox
            boxtype::subs: fullbox
            boxtype::saiz: fullbox
            boxtype::saio: fullbox
            boxtype::udta: box_container
            boxtype::cprt: fullbox
            boxtype::tsel: fullbox
            boxtype::kind: fullbox
            boxtype::strk: box_container
            boxtype::stri: fullbox
            boxtype::strd: box_container
            boxtype::ludt: fullbox
            boxtype::mvex: box_container
            boxtype::mehd: movie_extends_header_box
            boxtype::trex: track_extends_box
            boxtype::leva: fullbox
            boxtype::trep: track_extension_properties_box
            boxtype::moof: box_container
            boxtype::mfhd: fullbox
            boxtype::traf: box_container
            boxtype::tfhd: fullbox
            boxtype::trun: fullbox
            boxtype::tfdt: fullbox
            boxtype::mfra: box_container
            boxtype::tfra: fullbox
            boxtype::mfro: fullbox
            boxtype::mdat: dummy
            boxtype::free: box_container
            boxtype::skip: box_container
            boxtype::imda: box_container
            boxtype::iloc: fullbox
            boxtype::ipro: fullbox
            boxtype::sinf: box_container
            boxtype::frma: box_container
            boxtype::schm: fullbox
            boxtype::schi: box_container
            boxtype::iinf: fullbox
            boxtype::xml:  fullbox
            boxtype::bxml: fullbox
            boxtype::pitm: fullbox
            boxtype::fiin: fullbox
            boxtype::paen: fullbox
            boxtype::fire: fullbox
            boxtype::fpar: fullbox
            boxtype::fecr: fullbox
            boxtype::segr: fullbox
            boxtype::gitn: fullbox
            boxtype::idat: box_container
            boxtype::iref: fullbox
            boxtype::styp: general_type_box
            boxtype::sidx: fullbox
            boxtype::ssix: fullbox
            boxtype::prft: fullbox
            boxtype::c_mov: box_container
            boxtype::c_mof: box_container
            boxtype::c_six: box_container
            boxtype::c_ssx: box_container
    instances:
      len:
        value: 'size == 0 ? (_io.size - 8) : (size == 1 ? largesize - 16 : size - 8)'
    -webide-representation: '{boxtype}'

  fullbox:
    seq:
      - id: header
        type: fullbox_header
      - id: data
        size: len
    instances:
      len:
        value: '_parent.size == 0 ? (_io.size - 4) : (_parent.size == 1 ? _parent.largesize - 24 : _parent.size - 12)'

  fullbox_header:
    seq:
      - id: version
        type: u1
      - id: flags
        size: 3

  box_container:
    seq:
      - id: boxes
        type: box
        repeat: eos

  general_type_box:
    seq:
      - id: major_brand
        type: u4
        enum: brand
      - id: minor_version
        type: u4
      - id: compatible_brands
        type: u4
        enum: brand
        repeat: eos

  movie_header_box:
    doc: |
      MovieHeaderBox defines overall information which is media-independent, and
      relevant to the entire presentation considered as a whole.
    seq:
      - id: header
        type: fullbox_header
      - id: creation_time
        doc: |
          Declares the creation time of the presentation (in seconds since
          midnight, Jan. 1, 1904, in UTC time)
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4
      - id: modification_time
        doc: |
          Declares the most recent time the presentation was modified (in
          seconds since midnight, Jan. 1, 1904, in UTC time)
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4
      - id: time_scale
        type: u4
        doc: |
          A time value that indicates the time scale for this presentation - the
          number of time units that pass per second in its time coordinate
          system. A time coordinate system that measures time in sixtieths of a
          second, for example, has a time scale of 60.
      - id: duration
        doc: |
          A time value that indicates the duration of the movie in time scale
          units. Note that this property is derived from the movie's tracks. The
          value of this field corresponds to the duration of the longest track
          in the movie.
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4
      - id: rate
        type: fixed32_16int
        doc: |
          The rate at which to play this movie. A value of 1.0 indicates normal
          rate.
      - id: volume
        type: fixed16_8int
        doc: |
          How loud to play this movie's sound. A value of 1.0 indicates full
          volume.
      - id: reserved
        size: 10
      - id: matrix
        type: matrix
        doc: |
          A matrix shows how to map points from one coordinate space into
          another.
      - id: pre_defined
        type: u4
        repeat: expr
        repeat-expr: 6
      - id: next_track_id
        type: u4
        doc: |
          Indicates a value to use for the track ID number of the next track
          added to this movie. Note that 0 is not a valid track ID value.

  track_header_box:
    doc: |
      TrackHeaderBox specifies the characteristics of a single track. Exactly
      one TrackHeaderBox is contained in a track.
    seq:
      - id: version
        type: u1
      - id: flags
        type: track_header_flags
      - id: creation_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: modification_time
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: track_id
        type: u4
        doc: |
          Integer that uniquely identifies the track. The value 0 cannot be
          used.
      - id: reserved1
        size: 4
      - id: duration
        type:
          switch-on: version
          cases:
            1: u8
            _: u4
      - id: reserved2
        size: 8
      - id: layer
        doc: |
          Specifies the front-to-back ordering of video tracks; tracks with
          lower numbers are closer to the viewer. 0 is the normal value, and -1
          would be in front of track 0, and so on.
        type: u2
      - id: alternative_group
        doc: |
          An integer that specifies a group or collection of tracks. If this
          field is 0 there is no information on possible relations to other
          tracks. If this field is not 0, it should be the same for tracks that
          contain alternate data for one another and different for tracks
          belonging to different such groups. Only one track within an alternate
          group should be played or streamed at any one time, and shall be
          distinguishable from other tracks in the group via attributes such as
          bitrate, codec, language, packet size etc. A group may have only one
          member.
        type: u2
      - id: volume
        type: fixed16_8int
      - id: reserved3
        type: u2
      - id: matrix
        type: matrix
      - id: width
        doc: |
          For text and subtitle tracks, width and height may, depending on the
          coding format, describe the suggested size of the rendering area. For
          non-visual tracks (e.g. audio), they should be set to zero. For all
          other tracks, they specify the track's visual presentation size. These
          need not be the same as the pixel dimensions of the images, which is
          documented in the sample description(s); all images in the sequence
          are scaled to this size, before any overall transformation of the
          track represented by the matrix. The pixel dimensions of the images
          are the default values.
        type: fixed32_16int
      - id: height
        type: fixed32_16int

  track_header_flags:
    seq:
      - id: reserved
        type: b20
      - id: track_size_is_aspect_ratio
        doc: |
          The value 1 indicates that the width and height fields are not
          expressed in pixel units.
        type: b1
      - id: track_in_preview
        doc: |
          This flags currently has no assigned meaning, and the value should be
          ignored by readers.
        type: b1
      - id: track_in_movie
        doc: |
          The value 1 indicates that the track, or one of its alternatives (if
          any) forms a direct part of the presentation.
        type: b1
      - id: track_enabled
        doc: |
          A disabled track (this flags is zero) is treated as if it were not
          present.
        type: b1

  edit_list_box:
    doc: |
      EditListBox contains an explicit timeline map. Each entry defines part of
      the track timeline:: by mapping part of the composition timeline, or by
      indicating ‘empty’ time (portions of the presentation timeline
    seq:
      - id: version
        type: u1
      - id: flags
        size: 3
      - id: entry_count
        type: u4
      - id: entries
        type: edit_entry
        repeat: expr
        repeat-expr: entry_count
    instances:
      repeat_edits:
        doc: |
          When the edit list is repeated, media at time 0 resulting from the
          edit list follows immediately the media having the largest time
          resulting from the edit list. In other words, the edit list is
          repeated seamlessly.
        value: flags[2] & 0x1

  edit_entry:
    seq:
      - id: edit_duration
        doc: Specifies the duration of this edit in mdhd.time_scale units.
        type:
          switch-on: _parent.version
          cases:
            1: u8
            _: u4
      - id: media_time
        doc: |
          Indicates the starting time (in mdhd.time_scale units) within the
          media of this edit entry. If it is set to -1, it is an empty edit.
          edit_duration is the empty duration in the presentation (not play this
          media). The last edit in a track shall never be an empty edit.
        type:
          switch-on: _parent.version
          cases:
            1: s8
            _: s4
      - id: media_rate
        doc: |
          Specifies the relative rate at which to play the media corresponding
          to thie edit entry. 0 means a "dwell": the media would static at
          media_time for edit_duration.
        type: fixed32_16int

  media_header_box:
    seq:
      - id: header
        type: fullbox_header
      - id: creation_time
        doc: |
          Declares the creation time of the media in this track (in seconds
          since midnight, Jan. 1, 1904, in UTC time)
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4
      - id: modification_time
        doc: |
          Declares the most recent time the media in this track was modified (in
          seconds since midnight, Jan. 1, 1904, in UTC time)
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4
      - id: time_scale
        doc: |
          A time value that indicates the time scale for this media - the number
          of time units that pass per second in its time coordinate system. A
          time coordinate system that measures time in sixtieths of a second,
          for example, has a time scale of 60.
        type: u4
      - id: duration
        doc: |
          A time value that indicates the duration of this media in time scale
          units.
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4
      - id: language
        doc: ISO-639-2/T language code
        type: language
      - id: pre_defined
        type: u2

  handler_reference_box:
    seq:
      - id: header
        type: fullbox_header
      - id: pre_defined
        type: u4
      - id: handler_type
        doc: Specific media type of this track.
        type: str
        size: 4
        encoding: ASCII
      - id: reserved
        size: 12
      - id: name
        doc: |
          A human-readable name for the track type (for debugging and inspection
          purposes).
        type: strz
        encoding: UTF-8

  video_media_header_box:
    seq:
      - id: header
        type: fullbox_header
      - id: graphicsmode
        doc: |
          Specific a composition mode for this video track. 0 means copy over
          the existing image.
        type: u2
      - id: opcolor
        doc: |
          A set of 3 colour values (red, green, blue) available for use by
          graphics modes.
        type: opcolor

  opcolor:
    seq:
      - id: red
        type: u1
      - id: green
        type: u1
      - id: blue
        type: u1

  data_reference_box:
    doc: |
      DataRefecenceBox contains a table of data references (normally URLs) that
      declare the location(s) of the media data used within the presentation.
    seq:
      - id: header
        type: fullbox_header
      - id: entry_count
        type: u4
      - id: entries
        type: box
        repeat: expr
        repeat-expr: entry_count

  data_entry_url_box:
    seq:
      - id: header
        type: fullbox_header
      - id: location
        type: strz
        encoding: UTF-8
        if: entry_flag == 0
    instances:
      entry_flag:
        doc: |
          1 means that the media data is in the same file as the box containing
          this data reference. If this flag is set, the url box shall be used
          and no string is present; the box terminates with the entry-flags
          field.
        value: 'header.flags[2] & 0x1'

  data_entry_urn_box:
    seq:
      - id: header
        type: fullbox_header
      - id: name
        type: strz
        encoding: UTF-8
      - id: location
        type: strz
        encoding: UTF-8

  data_entry_imda_box:
    seq:
      - id: header
        type: fullbox_header
      - id: imda_ref_identifier
        doc: |
          Identifies the imda box (imda.imda_identifier == imda_ref_identifier)
          containing the media data (which is accessed through
          sample.data_reference_index in stsd box).
        type: u4

  sample_description_box:
    doc: |
      SampleDescriptionBox gives detailed information about the coding type
      used, and any initialization information needed for that coding.
    seq:
      - id: header
        type: fullbox_header
      - id: entry_count
        type: u4
      - id: entries
        type: box
        repeat: expr
        repeat-expr: entry_count

  time_to_sample_box:
    doc: |
      Contains a compact version of a table that allows indexing from decoding
      timestamp to sample number. Each entry gives the number of consecutive
      samples with the same sample duration. By adding the sample durations a
      complete time-to-sample map may be built.
    seq:
      - id: header
        type: fullbox_header
      - id: entry_count
        type: u4
      - id: entries
        type: stts_entry
        repeat: expr
        repeat-expr: entry_count

  stts_entry:
    seq:
      - id: sample_count
        type: u4
      - id: sample_delta
        doc: |
          The difference between the decoding timestamp of the next sample and
          this one (in the mdhd.time_scale units)
        type: u4

  sample_to_chunk_box:
    doc: |
      SampleToChunkBox is used to find the chunk that contains a sample, its
      position and the associated sample description.
    seq:
      - id: header
        type: fullbox_header
      - id: entry_count
        type: u4
      - id: entries
        type: stsc_entry
        repeat: expr
        repeat-expr: entry_count

  stsc_entry:
    seq:
      - id: first_chunk
        doc: |
          Gives the index of the first chunk in this run of chunks that share
          the same samples_per_chunk and sample_description_index; the index of
          the first chunk in a track has the value 1 (the first_chunk field in
          the first record of this box has the value 1, identifying that the
          first sample maps to the first chunk).
        type: u4
      - id: samples_per_chunk
        doc: Gives the number of samples in each of these chunks.
        type: u4
      - id: sample_description_index
        doc: |
          Gives the index of the sample entry that describes the samples in this
          chunk. The index ranges from 1 to the number of sample entries in the
          SampleDescriptionBox
        type: u4

  sample_size_box:
    doc: |
      This box contains the sample count and a table giving the size in bytes of
      each sample. This allows the media data itself to be unframed. The total
      number of samples in the media is always indicated in the sample count.
    seq:
      - id: header
        type: fullbox_header
      - id: sample_size
        type: u4
      - id: sample_count
        type: u4
      - id: entries
        if: sample_size == 0
        type: u4
        repeat: expr
        repeat-expr: sample_count

  movie_extends_header_box:
    seq:
      - id: header
        type: fullbox_header
      - id: fragment_duration
        doc: |
          Declares length of the presentation of the whole movie including
          fragments (in mvhd.time_scale units). The value of this field
          corresponds to the duration of the longest track, including movie
          fragments. If an MP4 file is created in real-time, such as used in
          live streaming, it is not likely that the fragment_duration is known
          in advance and this box may be omitted.
        type:
          switch-on: header.version
          cases:
            1: u8
            _: u4

  track_extends_box:
    seq:
      - id: header
        type: fullbox_header
      - id: track_id
        type: u4
      - id: default_sample_description_index
        type: u4
      - id: default_sample_duration
        type: u4
      - id: default_sample_size
        type: u4
      - id: default_sample_flags
        type: u4

  track_extension_properties_box:
    seq:
      - id: header
        type: fullbox_header
      - id: track_id
        type: u4
      - id: boxes
        type: box
        repeat: eos

  uuid:
    doc: uuid is used for unregistered box
    seq:
      - id: uuid
        size: 16

  matrix:
    seq:
      - id: a
        type: fixed32_16int
      - id: b
        type: fixed32_16int
      - id: u
        type: fixed32_2int
      - id: c
        type: fixed32_16int
      - id: d
        type: fixed32_16int
      - id: v
        type: fixed32_2int
      - id: x
        type: fixed32_16int
      - id: y
        type: fixed32_16int
      - id: w
        type: fixed32_2int

  language:
    seq:
      - id: pad
        type: b1
      - id: char1
        type: b5
      - id: char2
        type: b5
      - id: char3
        type: b5
    instances:
      code:
        value: '[char1 + 0x60, char2 + 0x60, char3 + 0x60].as<bytes>.to_s("ASCII")'

  fixed32_2int:
    doc: Fixed-point 2.30 number.
    seq:
      - id: int_part
        type: b2
      - id: frac_part
        type: b30

  fixed32_16int:
    doc: Fixed-point 16.16 number.
    seq:
      - id: int_part
        type: s2
      - id: frac_part
        type: u2

  fixed16_8int:
    doc: Fixed-point 8.8 number.
    seq:
      - id: int_part
        type: s1
      - id: frac_part
        type: u1

  dummy: {}


enums:

  boxtype:
    0x216d6f66: c_mof
    0x216d6f76: c_mov
    0x21736978: c_six
    0x21737378: c_ssx
    0x62786d6c: bxml
    0x636f3634: co64
    0x63707274: cprt
    0x63736c67: cslg
    0x63747473: ctts
    0x64696e66: dinf
    0x64726566: dref
    0x65647473: edts
    0x656c6e67: elng
    0x656c7374: elst
    0x66656372: fecr
    0x6669696e: fiin
    0x66697265: fire
    0x66706172: fpar
    0x66726565: free
    0x66726d61: frma
    0x66747970: ftyp
    0x6769746e: gitn
    0x68646c72: hdlr
    0x686d6864: hmhd
    0x69646174: idat
    0x69696e66: iinf
    0x696c6f63: iloc
    0x696d6461: imda
    0x696d6474: imdt
    0x6970726f: ipro
    0x69726566: iref
    0x6b696e64: kind
    0x6c657661: leva
    0x6c756474: ludt
    0x6d646174: mdat
    0x6d646864: mdhd
    0x6d646961: mdia
    0x6d656864: mehd
    0x6d657461: meta
    0x6d666864: mfhd
    0x6d667261: mfra
    0x6d66726f: mfro
    0x6d696e66: minf
    0x6d6f6f66: moof
    0x6d6f6f76: moov
    0x6d766578: mvex
    0x6d766864: mvhd
    0x6e6d6864: nmhd
    0x6f747970: otyp
    0x70616462: padb
    0x7061656e: paen
    0x7064696e: pdin
    0x7069746d: pitm
    0x70726674: prft
    0x7361696f: saio
    0x7361697a: saiz
    0x73626770: sbgp
    0x73636869: schi
    0x7363686d: schm
    0x73647470: sdtp
    0x73656772: segr
    0x73677064: sgpd
    0x73696478: sidx
    0x73696e66: sinf
    0x736b6970: skip
    0x736d6864: smhd
    0x736e696d: snim
    0x73736978: ssix
    0x7374626c: stbl
    0x7374636f: stco
    0x73746470: stdp
    0x73746864: sthd
    0x73747264: strd
    0x73747269: stri
    0x7374726b: strk
    0x73747363: stsc
    0x73747364: stsd
    0x73747368: stsh
    0x73747373: stss
    0x7374737a: stsz
    0x73747473: stts
    0x73747970: styp
    0x73747a32: stz2
    0x73756273: subs
    0x74666474: tfdt
    0x74666864: tfhd
    0x74667261: tfra
    0x746b6864: tkhd
    0x74726166: traf
    0x7472616b: trak
    0x74726566: tref
    0x74726578: trex
    0x74726570: trep
    0x74726772: trgr
    0x7472756e: trun
    0x7473656c: tsel
    0x75647461: udta
    0x75726c20: url
    0x75726e20: urn
    0x75756964: uuid
    0x766d6864: vmhd
    0x786d6c20: xml

  # https://mp4ra.org/#/brands
  #
  # JS code to scrape the enum `brand` (paste into the browser JS console on the above page):
  # ```javascript
  # copy(Array.from(document.querySelector('tbody').querySelectorAll('tr')).map(r => {
  #   const code = r.querySelector('td:nth-child(1)').innerText.replace(/\$20/g, '\x20');
  #   if (!code.trim()) return null;
  #   return [
  #     '0x' + Array.from((new TextEncoder()).encode(code), b => b.toString(16).padStart(2, '0')).join(''),
  #     (/^\d/.test(code) ? 'x_' : '') + code.trim().toLowerCase(),
  #   ];
  # }).filter(entry => !!entry).map(entry => `    ${entry[0]}: ${entry[1]}\n`).join(''));
  # ```
  brand:
    0x33673261: x_3g2a
    0x33676536: x_3ge6
    0x33676537: x_3ge7
    0x33676539: x_3ge9
    0x33676639: x_3gf9
    0x33676736: x_3gg6
    0x33676739: x_3gg9
    0x33676839: x_3gh9
    0x33676d39: x_3gm9
    0x33676d41: x_3gma
    0x33677034: x_3gp4
    0x33677035: x_3gp5
    0x33677036: x_3gp6
    0x33677037: x_3gp7
    0x33677038: x_3gp8
    0x33677039: x_3gp9
    0x33677236: x_3gr6
    0x33677239: x_3gr9
    0x33677336: x_3gs6
    0x33677339: x_3gs9
    0x33677438: x_3gt8
    0x33677439: x_3gt9
    0x33677476: x_3gtv
    0x33677672: x_3gvr
    0x33767261: x_3vra
    0x33767262: x_3vrb
    0x3376726d: x_3vrm
    0x61647469: adti
    0x61696433: aid3
    0x41525249: arri
    0x61763031: av01
    0x61766331: avc1
    0x61766369: avci
    0x61766373: avcs
    0x61766465: avde
    0x61766966: avif
    0x6176696f: avio
    0x61766973: avis
    0x6262786d: bbxm
    0x43414550: caep
    0x43446573: cdes
    0x6361346d: ca4m
    0x63613473: ca4s
    0x63616161: caaa
    0x63616163: caac
    0x6361626c: cabl
    0x63616d61: cama
    0x63616d63: camc
    0x63617176: caqv
    0x63617375: casu
    0x63636561: ccea
    0x63636666: ccff
    0x63646d31: cdm1
    0x63646d34: cdm4
    0x63656163: ceac
    0x63666864: cfhd
    0x63667364: cfsd
    0x63686431: chd1
    0x63686466: chdf
    0x63686576: chev
    0x63686864: chhd
    0x63686831: chh1
    0x636c6731: clg1
    0x636d6632: cmf2
    0x636d6663: cmfc
    0x636d6666: cmff
    0x636d666c: cmfl
    0x636d6673: cmfs
    0x636d686d: cmhm
    0x636d6873: cmhs
    0x636f6d70: comp
    0x63736831: csh1
    0x63756431: cud1
    0x63756438: cud8
    0x63757664: cuvd
    0x63766964: cvid
    0x63777674: cwvt
    0x64613061: da0a
    0x64613062: da0b
    0x64613161: da1a
    0x64613162: da1b
    0x64613261: da2a
    0x64613262: da2b
    0x64613361: da3a
    0x64613362: da3b
    0x64617368: dash
    0x64627931: dby1
    0x646d6231: dmb1
    0x64736d73: dsms
    0x64747331: dts1
    0x64747332: dts2
    0x64747333: dts3
    0x64763161: dv1a
    0x64763162: dv1b
    0x64763261: dv2a
    0x64763262: dv2b
    0x64763361: dv3a
    0x64763362: dv3b
    0x64767231: dvr1
    0x64767431: dvt1
    0x64786f20: dxo
    0x656d7367: emsg
    0x68656963: heic
    0x6865696d: heim
    0x68656973: heis
    0x68656978: heix
    0x68656f69: heoi
    0x68657663: hevc
    0x68657664: hevd
    0x68657669: hevi
    0x6865766d: hevm
    0x68657673: hevs
    0x68657678: hevx
    0x68766365: hvce
    0x68766369: hvci
    0x68766378: hvcx
    0x68767469: hvti
    0x69667364: ifsd
    0x69666873: ifhs
    0x69666864: ifhd
    0x69666878: ifhx
    0x69666868: ifhh
    0x69666875: ifhu
    0x69666872: ifhr
    0x69666161: ifaa
    0x6966726d: ifrm
    0x696d3169: im1i
    0x696d3174: im1t
    0x696d3269: im2i
    0x696d3274: im2t
    0x69736332: isc2
    0x69736f32: iso2
    0x69736f33: iso3
    0x69736f34: iso4
    0x69736f35: iso5
    0x69736f36: iso6
    0x69736f37: iso7
    0x69736f38: iso8
    0x69736f39: iso9
    0x69736f61: isoa
    0x69736f62: isob
    0x69736f63: isoc
    0x69736f6d: isom
    0x6a326b69: j2ki
    0x6a326b73: j2ks
    0x6a326973: j2is
    0x4a325030: j2p0
    0x4a325031: j2p1
    0x6a703220: jp2
    0x6a706567: jpeg
    0x6a706773: jpgs
    0x6a706d20: jpm
    0x6a706f69: jpoi
    0x6a707369: jpsi
    0x6a707820: jpx
    0x6a707862: jpxb
    0x6a786c20: jxl
    0x6a787320: jxs
    0x6a787363: jxsc
    0x6a787369: jxsi
    0x6a787373: jxss
    0x4c434147: lcag
    0x6c687465: lhte
    0x6c687469: lhti
    0x6c6d7367: lmsg
    0x4d344120: m4a
    0x4d344220: m4b
    0x4d345020: m4p
    0x4d345620: m4v
    0x4d413142: ma1b
    0x4d413141: ma1a
    0x4d46534d: mfsm
    0x4d475356: mgsv
    0x4d694142: miab
    0x4d694143: miac
    0x6d696166: miaf
    0x4d69416e: mian
    0x4d694275: mibu
    0x4d69436d: micm
    0x6d696631: mif1
    0x4d694841: miha
    0x4d694842: mihb
    0x4d694845: mihe
    0x4d695072: mipr
    0x6d6a3273: mj2s
    0x6d6a7032: mjp2
    0x6d703231: mp21
    0x6d703431: mp41
    0x6d703432: mp42
    0x6d703731: mp71
    0x4d505049: mppi
    0x6d707566: mpuf
    0x6d736631: msf1
    0x6d736468: msdh
    0x6d736978: msix
    0x4d534e56: msnv
    0x6e696b6f: niko
    0x6e6c736c: nlsl
    0x6e726173: nras
    0x6f613264: oa2d
    0x6f61626c: oabl
    0x6f646366: odcf
    0x6f6d7070: ompp
    0x6f706632: opf2
    0x6f707832: opx2
    0x6f766470: ovdp
    0x6f766c79: ovly
    0x70616666: paff
    0x70616e61: pana
    0x70696666: piff
    0x706d6666: pmff
    0x706e7669: pnvi
    0x71742020: qt
    0x72656c6f: relo
    0x72697378: risx
    0x524f5353: ross
    0x73647620: sdv
    0x53454155: seau
    0x5345424b: sebk
    0x73656e76: senv
    0x73696d73: sims
    0x73697378: sisx
    0x73697469: siti
    0x736c6831: slh1
    0x736c6832: slh2
    0x736c6833: slh3
    0x73737373: ssss
    0x74746d6c: ttml
    0x74747776: ttwv
    0x75687669: uhvi
    0x756e6966: unif
    0x75767675: uvvu
    0x76777074: vwpt
    0x58415643: xavc
    0x79743420: yt4
    0x63686432: chd2
    0x63696e74: cint
    0x636c6732: clg2
    0x63756432: cud2
    0x63756439: cud9
    0x6d696632: mif2
    0x70726564: pred
