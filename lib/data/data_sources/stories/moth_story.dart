import '../../models/story.dart';

const String _basePath = 'assets/images/stories/moth_story';

final Story mothStory = Story(
  id: 's4',
  coverAsset: '$_basePath/cover.png',
  category: StoryCategory.fables,
  content: {
    'english': StoryContent(
      title: 'The Tale of the Moth',
      pages: [
        StoryPage(
          text:
              'One evening, young Jose Rizal was sitting by an oil lamp with his mother. She began to tell him the story of the young moth.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'There were many moths flying around the oil lamp. They were drawn to its beautiful, golden light that brightened the dark room.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'An old moth saw the young moth circling the flame. She decided to give the little one a very important warning.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              '"Do not fly too close to the lamp," the mother moth warned. "The light is beautiful, but the heat will burn your wings!"',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'The young moth listened, but he was fascinated by the glow. "How can something so pretty be dangerous?" he wondered.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'He watched the light dance and thought the old moth was just being too careful. He wanted to feel the warmth of the flame.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Other insects flew near the lamp. He saw one beetle get too close and flutter away with a singed wing, but still, he stayed.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Ignoring the warnings, the young moth flew closer and closer. The golden light was so irresistible that he forgot all danger.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'Suddenly, the heat became too much! His delicate wings caught the flame. "Oh no!" he cried as he began to fall.',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'The moth fell to the table, unable to fly again. Young Jose never forgot this lesson: sometimes, being stubborn can lead to sadness.',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
    'filipino': StoryContent(
      title: 'Ang Kwento ng Gamu-gamo',
      pages: [
        StoryPage(
          text:
              'Isang gabi, ang batang si Jose Rizal ay nakaupo sa tabi ng lampara kasama ang kanyang ina. Sinimulan niyang ikwento ang tungkol sa batang gamu-gamo.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'Maraming mga gamu-gamo ang lumilipad sa paligid ng lampara. Sila ay naaakit sa maganda at gintong liwanag na nagbibigay-liwanag sa madilim na silid.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Nakita ng isang matandang gamu-gamo ang batang gamu-gamo na umiikot sa apoy. Nagpasya siyang bigyan ang maliit ng isang mahalagang babala.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              '"Huwag kang lumipad nang masyadong malapit sa lampara," babala ng inang gamu-gamo. "Maganda ang liwanag, ngunit susunugin ng init ang iyong mga pakpak!"',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Nakinig ang batang gamu-gamo, ngunit nabighani siya sa kislap. "Paano magiging mapanganib ang isang bagay na napakaganda?" tanong niya.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Pinanood niya ang pagsasayaw ng liwanag at inisip na masyadong maingat lang ang matandang gamu-gamo. Gusto niyang maramdaman ang init ng apoy.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Iba pang mga insekto ang lumipad malapit sa lampara. Nakita niya ang isang salagubang na masyadong lumapit at lumipad palayo na may sunog na pakpak.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Sa kabila ng mga babala, lumipad ang batang gamu-gamo nang palapit nang palapit. Ang gintong liwanag ay hindi niya matanggihan kaya nakalimutan niya ang panganib.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'Biglang naging napakainit! Ang kanyang manipis na mga pakpak ay nadikit sa apoy. "Naku po!" sigaw niya habang nagsimulang mahulog.',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Nahulog ang gamu-gamo sa mesa, hindi na makalipad muli. Hindi kailanman nakalimutan ng batang Jose ang aral na ito: kung minsan, ang katigasan ng ulo ay naghahatid ng kalungkutan.',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
    'hiligaynon': StoryContent(
      title: 'Ang Sugilanon sang Gamu-gamo',
      pages: [
        StoryPage(
          text:
              'Isa ka gab-i, ang bata nga si Jose Rizal nagapungko sa tupad sang lampara upod sa iya iloy. Ginsuguran niya ang pagsugid sang sugilanon sang pamatan-on nga gamu-gamo.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'Madamo nga mga gamu-gamo ang nagalupad-lupad sa palibot sang lampara. Nawili sila sa matahom kag masulhay nga kasanag nga nagapasanag sa madulom nga hulot.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Nakita sang isa ka tigulang nga gamu-gamo ang pamatan-on nga gamu-gamo nga nagalibot sa kalayo. Nagdesisyon sia nga hatagan ang gamay sang isa ka importante nga paandam.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              '"Indi ka maglupad sing malapit sa lampara," paandam sang iloy nga gamu-gamo. "Matahom ang kasanag, pero ang init magasunog sang imo mga pakpak!"',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Nagpamati ang pamatan-on nga gamu-gamo, pero nawili gid sia sa kasanag. "Paano mangin delikado ang isa ka butang nga tuman katahom?" pamangkot niya.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Ginhulot niya ang pagsinaot sang kasanag kag naghunahuna nga masyado lang mainandamon ang tigulang nga gamu-gamo. Gusto niya mabatyagan ang init sang kalayo.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Iban pa nga mga insekto ang naglupad malapit sa lampara. Nakita niya ang isa ka kulasisi nga tuman ka malapit kag naglupad palayo nga may nasunog nga pakpak.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Bangud sa pagbalewala sa mga paandam, naglupad ang pamatan-on nga gamu-gamo sing mas malapit pa gid. Ang kasanag tuman gid ka daku nga nakalimtan niya ang peligro.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'Hinali lang nga nag-init gid sing todo! Ang iya manipis nga mga pakpak nasunog sa kalayo. "Ayay!" singgit niya samtang nagasugod na sia sa pagkahulog.',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Nahulog ang gamu-gamo sa lamesa, indi na makalupad liwat. Wala gid malimtan sang bata nga Jose ang ini nga leksyon: kon kaisa, ang katigasan sang ulo nagadala sang kasubo.',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
  },
);
