import '../../models/story.dart';

const String _basePath = 'assets/images/stories/kanlaon_story';

final Story legendOfKanlaon = Story(
  id: 's2',
  coverAsset: '$_basePath/cover.png',
  category: StoryCategory.legends,
  content: {
    'english': StoryContent(
      title: 'The Legend of Mount Kanlaon',
      pages: [
        StoryPage(
          text:
              'Long ago, the island of Negros was ruled by a kind king. The kingdom was peaceful and prosperous, except for one terrible problem: a massive, fire-breathing green dragon with seven heads lived on the highest mountain.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'To keep the beast from destroying their villages, the people had to appease it by sacrificing one beautiful young maiden to the dragon every year. Eventually, only the King’s own daughter remained.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Just as the princess was about to be taken to the mountain, a young foreigner named Laon arrived. prince from a distant land, known for his bravery and wisdom, he volunteered to slay the dragon.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              'Laon had the ability to speak to animals. He called upon the creatures of the forest to help him: an army of ants, a swarm of bees, and a giant eagle.',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'The battle was fierce! First, millions of ants crawled all over the dragon\'s body, biting it and blinding its many eyes.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Then, the bees swarmed the beast, stinging its seven faces and confusing it, making the dragon roar in pain.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'The giant eagle swooped down, distracting the dragon with its massive wings while Laon prepared his magic sword.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'With the dragon distracted, Laon drew his magical sword and with swift, powerful strikes, he beheaded all seven heads of the dragon.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'The kingdom rejoiced! The King gave Laon his daughter\'s hand in marriage. The people named the mountain "Kanlaon," which means "For Laon."',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Today, Mount Kanlaon is an active volcano. Locals believe that whenever it smokes or erupts, it is the defeated dragon stirring in its grave.',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
    'filipino': StoryContent(
      title: 'Alamat ng Bundok Kanlaon',
      pages: [
        StoryPage(
          text:
              'Noong unang panahon, ang isla ng Negros ay pinamumunuan ng isang mabait na hari. Ang kaharian ay payapa, maliban sa isang malaking problema: isang nagbubuga ng apoy na berdeng dragon na may pitong ulo na nakatira sa pinakamataas na bundok.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'Upang hindi sirain ng halimaw ang kanilang mga nayon, kailangang mag-alay ang mga tao ng isang magandang dalaga sa dragon taon-taon. Sa huli, ang anak na babae na lamang ng Hari ang natira.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Noong dadalhin na ang prinsesa sa bundok, dumating ang isang dayuhang nagngangalang Laon. Isang prinsipe mula sa malayong lupain na kilala sa tapang at talino, nagboluntaryo siyang patayin ang dragon.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              'May kakayahan si Laon na makipag-usap sa mga hayop. Tinawag niya ang mga nilalang ng kagubatan upang tulungan siya: isang hukbo ng mga langgam, kawan ng mga pukyutan, at isang higanteng agila.',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Naging matindi ang labanan! Una, milyon-milyong mga langgam ang gumapang sa buong katawan ng dragon, kinakagat ito at binubulag ang maraming mata nito.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Pagkatapos, ang mga pukyutan ay sumugod sa halimaw, tinutusok ang pitong mukha nito at nililito ang dragon.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Ang higanteng agila ay bumaba, ginugulo ang dragon gamit ang malalaking pakpak nito habang inihahanda ni Laon ang kanyang mahiwagang espada.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Dahil sa pagkalito ng dragon, inilabas ni Laon ang kanyang mahiwagang espada at pinugutan ang lahat ng pito nitong ulo.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'Nagsaya ang buong kaharian! Ipinakasal ng Hari si Laon sa kanyang anak. Pinangalanan ng mga tao ang bundok na "Kanlaon," na ang ibig sabihin ay "Para kay Laon."',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Ngayon, ang Bundok Kanlaon ay isang aktibong bulkan. Naniniwala ang mga lokal na tuwing nagbubuga ito ng usok, ito ay ang natalong dragon na gumagalaw sa kanyang libingan.',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
    'hiligaynon': StoryContent(
      title: 'Ang Alamat sang Bukid Kanlaon',
      pages: [
        StoryPage(
          text:
              'Sang una nga panahon, ang isla sang Negros ginadumalahan sang isa ka mabuot nga hari. Maliban sa isa ka dako nga problema: isa ka dragon nga nagabuga sang kalayo kag may pito ka ulo nga nagaistar sa pinakamataas nga bukid.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'Para indi paggubaon sang dragon ang ila baryo, kinahanglan maghalad sang isa ka matahom nga dalaga kada tuig. Sang ulihi, ang anak na lang sang Hari ang nabilin.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Sang dal-on na ang prinsesa sa bukid, nag-abot ang isa ka dumuluong nga si Laon. Isa ka prinsipe nga kilala sa kaisog, nagboluntaryo siya nga patyon ang dragon.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              'May ikasarang si Laon nga mag-istorya sa mga sapat. Gintawag niya ang mga pispis kag insekto sa kagubatan: mga subay, mga pukyutan, kag isa ka dako nga agila.',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Grabe ang inaway! Una, minilyon nga mga subay ang nagkamang sa lawas sang dragon kag ginkagat ang iya mga mata.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Sunod, ang mga pukyutan nagdugok sa dragon kag ginkagat ang iya pito ka nawong.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Ang dako nga agila naglupad sa ibabaw sang dragon para gub-on ang iya konsentrasyon samtang ginahanda ni Laon ang iya mahiko nga espada.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Gingamit ni Laon ang iya mahiko nga espada kag gin-utod ang pito ka ulo sang dragon.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'Nalipay ang tanan! Ginkasal ang prinsesa kay Laon. Ginkilala ang bukid bilang "Kanlaon," ukon "Para kay Laon."',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Subong, ang Bukid Kanlaon isa ka bulkan. Nagapati ang mga tawo nga kon mag-aso ini, ang dragon sa idalom nagahulag sa iya lulubngan.',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
  },
);
