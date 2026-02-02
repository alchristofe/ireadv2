import '../../models/story.dart';

const String _basePath = 'assets/images/stories/monkey_turtle';

final Story monkeyAndTurtle = Story(
  id: 's1',
  coverAsset: '$_basePath/cover.png',
  category: StoryCategory.fables,
  content: {
    'filipino': StoryContent(
      title: 'Ang Pagong at ang Matsing',
      pages: [
        StoryPage(
          text:
              'Isang araw, ang matalinong Matsing at ang mabagal na Pagong ay naglalakad sa tabing-ilog nang makakita sila ng lumulutang na puno ng saging. Napagkasunduan nilang hatiin ito.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'Agad na kinuha ng sakim na Matsing ang itaas na bahagi, sa pag-aakalang ito ang pinakamaganda dahil may mga berdeng dahon na ito at ilang bunga. Naiwan sa Pagong ang ibabang bahagi na may mga ugat.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Pareho nilang itinanim ang kanilang mga bahagi. Ang itaas na bahagi ng Matsing, dahil walang ugat, ay agad na natuyo at namatay. Ngunit ang ibaba ng Pagong ay lumaki at naging isang magandang puno na may maraming dilaw na saging.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              'Tuwang-tuwa ang Pagong ngunit hindi siya makapandakyat sa puno para kunin ang mga bunga. Nakita ito ng Matsing at nag-alok na tumulong, ngunit ang totoo ay balak niyang solohin ang mga saging.',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Pagkaakyat ng puno, sinimulan ng Matsing na kainin ang lahat ng hinog na saging, binalewala ang mga pakiusap ng Pagong sa ibaba. Hindi lang iyon, tinapon pa niya ang mga balat ng saging sa Pagong.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Nasaktan at nagalit, nagpasya ang Pagong na turuan ng leksyon ang Matsing. Kumuha siya ng mga matutulis na tinik at itinusok ang mga ito sa katawan ng puno.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Nang bumaba ang Matsing, busog na busog, natusok siya ng mga tinik at napasigaw sa sakit.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Galit na galit, hinanap ng Matsing ang Pagong at nagbantang papatayin ito. Binigyan niya ang Pagong ng parusa: ang durugin siya gamit ang almires o itapon sa malalim na ilog.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'Ginamit ng Pagong ang kaniyang talino. "Durugin mo na lang ako! Huwag mo lang akong itapon sa tubig! Malulunod ako!" pakiusap niya.',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Itinapon ng Matsing ang Pagong sa ilog bilang pinakamatinding parusa. Ngunit pagbagsak sa tubig, tumawa ang Pagong. "Hangal! Ang tubig ay ang aking tahanan!"',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
    'english': StoryContent(
      title: 'The Monkey and the Turtle',
      pages: [
        StoryPage(
          text:
              'One day, a clever Monkey and a slow Turtle were walking along the riverbank when they found a floating banana tree. Deciding to share it, they pulled it ashore and cut it in half.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'The greedy Monkey immediately claimed the top half, thinking it was the best part because it already had green leaves and some fruit. The Turtle was left with the bottom half, which had the roots.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'They both planted their halves. The Monkey’s top half, having no roots, quickly withered and died. But the Turtle’s bottom half grew into a beautiful tree bearing a large bunch of delicious yellow bananas.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              'The Turtle was delighted but couldn\'t climb the tree to harvest the fruit. The Monkey saw this and offered to help, secretly plotting to take the bananas for himself.',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Once up the tree, the Monkey started eating all the ripe bananas, ignoring the Turtle\'s pleas below. To add insult to injury, the Monkey threw the banana peels down at the Turtle.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Hurt and angry, the Turtle decided to teach the Monkey a lesson. He gathered sharp thorns and stuck them into the bark around the bottom of the banana tree.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'When the Monkey finally climbed down, his stomach full, he was pricked by the thorns and howled in pain.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Furious, the Monkey found the Turtle and threatened to kill him. He gave the Turtle a choice of punishment: being crushed with a mortar or thrown into the river.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              'The clever Turtle used reverse psychology. He cried out, "Please, crush me into pieces! But please, whatever you do, do not throw me into the water! I will drown!"',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Thinking this was the perfect way to make the Turtle suffer, the Monkey grabbed the Turtle and threw him into the river. "You fool!" the Turtle cheered. "Water is my home!"',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
    'hiligaynon': StoryContent(
      title: 'Ang Amo kag ang Pag-ong',
      pages: [
        StoryPage(
          text:
              'Isa ka adlaw, may mauti nga Amo kag mahinay nga Pag-ong nga nagatunog (nagalakat) sa higad sang suba sang nakakita sila sang nagalutaw nga puno sang saging. Nagdesisyon sila nga tungaon ini.',
          imageAsset: '$_basePath/page1.png',
        ),
        StoryPage(
          text:
              'Gilayon nga ginkuha sang makagod nga Amo ang ibabaw nga bahagi, sa paghunahuna nga amo ini ang pinakamaayo tungod may mga dahon na ini kag bunga. Ang Pag-ong naman ang nakakuha sang idalom nga bahagi nga may mga gamut.',
          imageAsset: '$_basePath/page2.png',
        ),
        StoryPage(
          text:
              'Pareho nila nga gintanum ang ila mga bahagi. Ang sa Amo, tungod wala sang gamut, gilayon nga nalaya kag napatay. Apang ang sa Pag-ong nangin matahom nga puno kag nagbunga sang madamo nga saging.',
          imageAsset: '$_basePath/page3.png',
        ),
        StoryPage(
          text:
              'Nalipay gid ang Pag-ong apang indi siya makasaka sa puno. Nakita ini sang Amo kag nagtanyag nga magbulig, apang may malain siya nga plano.',
          imageAsset: '$_basePath/page4.png',
        ),
        StoryPage(
          text:
              'Pagkasaka sang Amo, ginkaon niya ang tanan nga hinog nga saging. Ginhaboy pa niya ang mga panit sang saging sa Pag-ong sa idalom.',
          imageAsset: '$_basePath/page5.png',
        ),
        StoryPage(
          text:
              'Tungod sa kaakig, nagbutang ang Pag-ong sang mga tunok sa puno sang saging.',
          imageAsset: '$_basePath/page6.png',
        ),
        StoryPage(
          text:
              'Pagpanaog sang Amo, natusok siya sang mga tunok kag nagsinggit sa kasakit.',
          imageAsset: '$_basePath/page7.png',
        ),
        StoryPage(
          text:
              'Akig gid ang Amo kag gusto niya patyon ang Pag-ong. Ginpapili niya ang Pag-ong: dugdugon sa almires ukon ihaboy sa suba.',
          imageAsset: '$_basePath/page8.png',
        ),
        StoryPage(
          text:
              '"Dugduga lang ako! Palihog indi lang ako ihaboy sa suba! Malunod ako!" siling sang mauti nga Pag-ong.',
          imageAsset: '$_basePath/page9.png',
        ),
        StoryPage(
          text:
              'Gihaboy siya sang Amo sa suba. Pag-abot sa tubig, nagkadlaw ang Pag-ong. "Amo! Ang tubig amo ang aking puluy-an!"',
          imageAsset: '$_basePath/page10.png',
        ),
      ],
    ),
  },
);
