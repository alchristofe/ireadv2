import '../../models/story.dart';

// Shared list of images for all languages
// Change the image path here, and it will update for English, Filipino, and Hiligaynon automatically.
final List<String> _lamAngImages = [
  'assets/images/stories/lam_ang_story/lam-ang_p1.png', // Page 1
  'assets/images/stories/lam_ang_story/lam-ang_p2.png', // Page 2
  'assets/images/stories/lam_ang_story/lam-ang_p3.png', // Page 3
  'assets/images/stories/lam_ang_story/lam-ang_p4.png', // Page 4
  'assets/images/stories/lam_ang_story/lam-ang_p5.png', // Page 5
  'assets/images/stories/lam_ang_story/lam-ang_p6.png', // Page 6
  'assets/images/stories/lam_ang_story/lam-ang_p7.png', // Page 7
  'assets/images/stories/lam_ang_story/lam-ang_p8.png', // Page 8
  'assets/images/stories/lam_ang_story/lam-ang_p9.png', // Page 9
  'assets/images/stories/lam_ang_story/lam-ang_p10.png', // Page 10
  'assets/images/stories/lam_ang_story/lam-ang_p11.png', // Page 11
  'assets/images/stories/lam_ang_story/lam-ang_p12.png', // Page 12
  'assets/images/stories/lam_ang_story/lam-ang_p13.png', // Page 13
  'assets/images/stories/lam_ang_story/lam-ang_p14.png', // Page 14
  'assets/images/stories/lam_ang_story/lam-ang_p15.png', // Page 15
  'assets/images/stories/lam_ang_story/lam-ang_p16.png', // Page 16
  'assets/images/stories/lam_ang_story/lam-ang_p17.png', // Page 17
  'assets/images/stories/lam_ang_story/lam-ang_p18.png', // Page 18
  'assets/images/stories/lam_ang_story/lam-ang_p19.png', // Page 19
  'assets/images/stories/lam_ang_story/lam-ang_p20.png', // Page 20
  'assets/images/stories/lam_ang_story/lam-ang_p21.png', // Page 21
  'assets/images/app_icon.png', // Page 22
  'assets/images/app_icon.png', // Page 23
];

final Story biagNiLamAng = Story(
  id: 's4',
  coverAsset: 'assets/images/stories/lam_ang_story/lam_ang_cover.png',
  category: StoryCategory.epics,
  content: {
    'english': StoryContent(
      title: 'The Life of Lam-ang',
      pages: [
        // Part 1: The Magical Boy
        StoryPage(
          text:
              'Part 1: The Magical Boy\n\nOnce upon a time, there lived a brave couple named Don Juan and Namongan. They lived in a place called Nalbuan.',
          imageAsset: _lamAngImages[0],
        ),
        StoryPage(
          text:
              'One day, Don Juan had to go to the mountains. He promised to come back soon. Namongan waited for him.',
          imageAsset: _lamAngImages[1],
        ),
        StoryPage(
          text:
              'Soon, Namongan had a baby boy. But this was no ordinary baby! As soon as he was born, he spoke. "Hello, Mother! My name is Lam-ang."',
          imageAsset: _lamAngImages[2],
        ),
        StoryPage(
          text:
              'Lam-ang grew very fast. At nine months old, he was already as strong as a man. He asked, "Where is my father?"',
          imageAsset: _lamAngImages[3],
        ),
        // Part 2: The Adventure
        StoryPage(
          text:
              'Part 2: The Adventure\n\nHis mother told him his father was still in the mountains. "I will find him!" said Lam-ang. He took a long journey.',
          imageAsset: _lamAngImages[4],
        ),
        StoryPage(
          text:
              'In the mountains, Lam-ang found the enemies who had hurt his father. He was very angry, but he was also very brave.',
          imageAsset: _lamAngImages[5],
        ),
        StoryPage(
          text:
              'Lam-ang used his magic and strength. Bam! Pow! He defeated all the bad guys all by himself!',
          imageAsset: _lamAngImages[6],
        ),
        StoryPage(
          text:
              'Lam-ang went home a hero. But he was very dirty from the fight! He went to the river to take a bath.',
          imageAsset: _lamAngImages[7],
        ),
        StoryPage(
          text:
              'When Lam-ang jumped in, the dirt washed off. He was so powerful that the dirt made the fish in the river swim away!',
          imageAsset: _lamAngImages[8],
        ),
        // Part 3: The Beautiful Princess
        StoryPage(
          text:
              'Part 3: The Beautiful Princess\n\nNow clean and handsome, Lam-ang wanted to meet Ines. She was the most beautiful girl in the land. He brought his magic White Rooster and Gray Dog.',
          imageAsset: _lamAngImages[9],
        ),
        StoryPage(
          text:
              'On the way, a giant tried to stop him. But Lam-ang was stronger. He pushed the giant away easily. Nothing could stop him!',
          imageAsset: _lamAngImages[10],
        ),
        StoryPage(
          text:
              'Lam-ang arrived at Ines’s big house. There were many people there. Lam-ang told his Rooster to crow. Cock-a-doodle-doo!',
          imageAsset: _lamAngImages[11],
        ),
        StoryPage(
          text:
              'Then, Lam-ang told his Dog to bark. Woof! Woof! The house that fell down stood up again! It was magic!',
          imageAsset: _lamAngImages[12],
        ),
        StoryPage(
          text:
              'Ines and her parents liked Lam-ang. They said he could marry Ines if he brought them gold. So, Lam-ang brought two ships full of gold!',
          imageAsset: _lamAngImages[13],
        ),
        // Part 4: The Monster Fish
        StoryPage(
          text:
              'Part 4: The Monster Fish\n\nLam-ang and Ines had a beautiful wedding. Everyone was happy.',
          imageAsset: _lamAngImages[14],
        ),
        StoryPage(
          text:
              'But Lam-ang had one more task. He had to catch a special fish in the river. He knew it was dangerous.',
          imageAsset: _lamAngImages[15],
        ),
        StoryPage(
          text:
              '"If the stairs dance and the stove breaks," he told Ines, "it means something bad happened to me."',
          imageAsset: _lamAngImages[16],
        ),
        StoryPage(
          text:
              'Lam-ang dove into the water. Suddenly, a giant monster fish called Berkakan ate him!',
          imageAsset: _lamAngImages[17],
        ),
        StoryPage(
          text:
              'At home, the stairs danced and the stove broke. Ines cried. She knew Lam-ang was gone.',
          imageAsset: _lamAngImages[18],
        ),
        // Part 5: A Happy Ending
        StoryPage(
          text:
              'Part 5: A Happy Ending\n\nBut the White Rooster said, "Don\'t cry! We can save him!" They asked a diver to get Lam-ang’s bones from the river.',
          imageAsset: _lamAngImages[19],
        ),
        StoryPage(
          text:
              'The Rooster crowed, and the Dog barked at the bones. Magic sparks flew everywhere!',
          imageAsset: _lamAngImages[20],
        ),
        StoryPage(
          text:
              'Slowly, Lam-ang woke up! He was alive again! He hugged Ines tightly.',
          imageAsset: _lamAngImages[21],
        ),
        StoryPage(
          text:
              'Lam-ang, Ines, the Rooster, and the Dog lived happily ever after.',
          imageAsset: _lamAngImages[22],
        ),
      ],
    ),
    'filipino': StoryContent(
      title: 'Biag ni Lam-ang',
      pages: [
        // Part 1
        StoryPage(
          text:
              'Bahagi 1: Ang Mahiyaing Batang Lalaki\n\nNoong unang panahon, may isang matapang na mag-asawa na sina Don Juan at Namongan. Nakatira sila sa lugar na tinatawag na Nalbuan.',
          imageAsset: _lamAngImages[0],
        ),
        StoryPage(
          text:
              'Isang araw, kailangan pumunta ni Don Juan sa kabundukan. Nangako siyang babalik agad. Naghintay si Namongan sa kanya.',
          imageAsset: _lamAngImages[1],
        ),
        StoryPage(
          text:
              'Sa wakas, nanganak si Namongan ng isang sanggol na lalaki. Ngunit hindi ito ordinaryong sanggol! Pagkasilang pa lang, nagsalita na siya. "Kamusta, Ina! Ang pangalan ko ay Lam-ang."',
          imageAsset: _lamAngImages[2],
        ),
        StoryPage(
          text:
              'Mabilis lumaki si Lam-ang. Sa edad na siyam na buwan, kasinglakas na siya ng isang lalaki. Tinanong niya, "Nasaan ang aking ama?"',
          imageAsset: _lamAngImages[3],
        ),
        // Part 2
        StoryPage(
          text:
              'Bahagi 2: Ang Pakikipagsapalaran\n\nSinabi ng kanyang ina na ang kanyang ama ay nasa kabundukan pa rin. "Hahanapin ko siya!" sabi ni Lam-ang. Naglakbay siya nang malayo.',
          imageAsset: _lamAngImages[4],
        ),
        StoryPage(
          text:
              'Sa kabundukan, nahanap ni Lam-ang ang mga kaaway na nanakit sa kanyang ama. Galit na galit siya, ngunit siya rin ay napakatapang.',
          imageAsset: _lamAngImages[5],
        ),
        StoryPage(
          text:
              'Ginamit ni Lam-ang ang kanyang mahika at lakas. Bog! Pak! Tinalo niya ang lahat ng masasamang loob nang mag-isa!',
          imageAsset: _lamAngImages[6],
        ),
        StoryPage(
          text:
              'Umuwi si Lam-ang bilang isang bayani. Ngunit napakarumi niya mula sa laban! Pumunta siya sa ilog upang maligo.',
          imageAsset: _lamAngImages[7],
        ),
        StoryPage(
          text:
              'Nang tumalon si Lam-ang, natanggal ang lahat ng dumi. Sa sobrang lakas niya, ang dumi ay nagpalayo sa mga isda sa ilog!',
          imageAsset: _lamAngImages[8],
        ),
        // Part 3
        StoryPage(
          text:
              'Bahagi 3: Ang Magandang Prinsesa\n\nNgayong malinis at gwapo na, gusto ni Lam-ang na makilala si Ines. Siya ang pinakamagandang babae sa lupain. Dala niya ang kanyang mahiwagang Puting Tandang at Asong Abo.',
          imageAsset: _lamAngImages[9],
        ),
        StoryPage(
          text:
              'Sa daan, sinubukan siyang pigilan ng isang higante. Ngunit mas malakas si Lam-ang. Tinulak niya ang higante nang madali. Walang makakapigil sa kanya!',
          imageAsset: _lamAngImages[10],
        ),
        StoryPage(
          text:
              'Dumating si Lam-ang sa malaking bahay ni Ines. Maraming tao doon. Inutusan ni Lam-ang ang kanyang Tandang na tumilaok. Tik-tilaok!',
          imageAsset: _lamAngImages[11],
        ),
        StoryPage(
          text:
              'Pagkatapos, inutusan ni Lam-ang ang kanyang Aso na tumahol. Aw! Aw! Ang bahay na gumuho ay tumayo muli! Isa itong mahika!',
          imageAsset: _lamAngImages[12],
        ),
        StoryPage(
          text:
              'Nagustuhan ni Ines at ng kanyang mga magulang si Lam-ang. Sinabi nila na pwede niyang pakasalan si Ines kung magdadala siya ng ginto. Kaya, nagdala si Lam-ang ng dalawang barkong puno ng ginto!',
          imageAsset: _lamAngImages[13],
        ),
        // Part 4
        StoryPage(
          text:
              'Bahagi 4: Ang Halimaw na Isda\n\nNagkaroon ng magandang kasal sina Lam-ang at Ines. Masaya ang lahat.',
          imageAsset: _lamAngImages[14],
        ),
        StoryPage(
          text:
              'Ngunit may isa pang pagsubok si Lam-ang. Kailangan niyang hulihin ang isang espesyal na isda sa ilog. Alam niyang mapanganib ito.',
          imageAsset: _lamAngImages[15],
        ),
        StoryPage(
          text:
              '"Kapag sumayaw ang hagdan at nasira ang kalan," sabi niya kay Ines, "ibig sabihin may masamang nangyari sa akin."',
          imageAsset: _lamAngImages[16],
        ),
        StoryPage(
          text:
              'Sumisid si Lam-ang sa tubig. Bigla, kinain siya ng isang higanteng halimaw na isda na tinatawag na Berkakan!',
          imageAsset: _lamAngImages[17],
        ),
        StoryPage(
          text:
              'Sa bahay, sumayaw ang hagdan at nasira ang kalan. Umiyak si Ines. Alam niyang wala na si Lam-ang.',
          imageAsset: _lamAngImages[18],
        ),
        // Part 5
        StoryPage(
          text:
              'Bahagi 5: Isang Masayang Katapusan\n\nNgunit sinabi ng Puting Tandang, "Huwag kang umiyak! Maililigtas natin siya!" Nakiusap sila sa isang maninisid na kunin ang mga buto ni Lam-ang sa ilog.',
          imageAsset: _lamAngImages[19],
        ),
        StoryPage(
          text:
              'Tumilaok ang Tandang, at tumahol ang Aso sa mga buto. Nagliparan ang mga mahiwagang kislap!',
          imageAsset: _lamAngImages[20],
        ),
        StoryPage(
          text:
              'Unti-unti, nagising si Lam-ang! Buhay na siya muli! Niyakap niya nang mahigpit si Ines.',
          imageAsset: _lamAngImages[21],
        ),
        StoryPage(
          text:
              'Namuhay nang masaya sina Lam-ang, Ines, ang Tandang, at ang Aso magpakailanman.',
          imageAsset: _lamAngImages[22],
        ),
      ],
    ),
    'hiligaynon': StoryContent(
      title: 'Ang Kabuhi ni Lam-ang',
      pages: [
        // Part 1
        StoryPage(
          text:
              'Parte 1: Ang Mahiko nga Bata\n\nSang una nga panahon, may maisog nga mag-asawa nga kanday Don Juan kag Namongan. Naga-istar sila sa lugar nga ginatawag Nalbuan.',
          imageAsset: _lamAngImages[0],
        ),
        StoryPage(
          text:
              'Isa ka adlaw, kinahanglan magkadto ni Don Juan sa bukid. Nagpromisa siya nga mabalik dayon. Naghulat si Namongan sa iya.',
          imageAsset: _lamAngImages[1],
        ),
        StoryPage(
          text:
              'Sang ulihi, nagbata si Namongan sang isa ka lalaki. Pero indi ini ordinaryo nga bata! Pagkatawo pa lang, naghambal na siya. "Kumusta, Iloy! Ang ngalan ko si Lam-ang."',
          imageAsset: _lamAngImages[2],
        ),
        StoryPage(
          text:
              'Dasig nagdako si Lam-ang. Sa edad nga siyam ka bulan, pareho na siya kakusog sa isa ka lalaki. Pamangkot niya, "Diin ang akon amay?"',
          imageAsset: _lamAngImages[3],
        ),
        // Part 2
        StoryPage(
          text:
              'Parte 2: Ang Paglakbay\n\nGinsugiran siya sang iya iloy nga ang iya amay ara pa sa bukid. "Pangitaon ko siya!" siling ni Lam-ang. Naglakat siya sa malayo nga lugar.',
          imageAsset: _lamAngImages[4],
        ),
        StoryPage(
          text:
              'Sa bukid, nakit-an ni Lam-ang ang mga kaaway nga naghalit sa iya amay. Akig gid siya, pero maisog man siya katama.',
          imageAsset: _lamAngImages[5],
        ),
        StoryPage(
          text:
              'Gingamit ni Lam-ang ang iya mahika kag kusog. Bog! Pak! Napierde niya ang tanan nga malain nga tawo nga siya lang isa!',
          imageAsset: _lamAngImages[6],
        ),
        StoryPage(
          text:
              'Nagpauli si Lam-ang nga baganihan. Pero pwerte sa iya kahigko halin sa away! Nagkadto siya sa suba para magpaligo.',
          imageAsset: _lamAngImages[7],
        ),
        StoryPage(
          text:
              'Sang paglukso ni Lam-ang, nagkakas ang tanan nga higko. Sa iya nga kusog, ang higko nagpalayo sa mga isda sa suba!',
          imageAsset: _lamAngImages[8],
        ),
        // Part 3
        StoryPage(
          text:
              'Parte 3: Ang Matahom nga Prinsesa\n\nSubong nga matinlo kag guapo na, gusto ni Lam-ang nga makilala si Ines. Siya ang pinakaguapa nga babayi sa lugar. Dala niya ang iya mahiko nga Puti nga Manok kag Abo nga Ido.',
          imageAsset: _lamAngImages[9],
        ),
        StoryPage(
          text:
              'Sa dalan, ginpunggan siya sang isa ka higante. Pero mas makusog si Lam-ang. Gintulod niya ang higante nga daw wala lang. Wala sing makapugong sa iya!',
          imageAsset: _lamAngImages[10],
        ),
        StoryPage(
          text:
              'Nakaabot si Lam-ang sa dako nga balay ni Ines. Madamo didto sang tawo. Ginsugo ni Lam-ang ang iya Manok nga magpamalo. Tiktilaok!',
          imageAsset: _lamAngImages[11],
        ),
        StoryPage(
          text:
              'Dayon, ginsugo ni Lam-ang ang iya Ido nga mag-usig. Aw! Aw! Ang balay nga naguba nagtindog liwat! Isa yadto ka mahika!',
          imageAsset: _lamAngImages[12],
        ),
        StoryPage(
          text:
              'Nagustuhan ni Ines kag sang iya mga ginikanan si Lam-ang. Nagsiling sila nga pwede niya pakaslan si Ines kung magdala siya sang bulawan. Gani, nagdala si Lam-ang sang duha ka barko nga puno sang bulawan!',
          imageAsset: _lamAngImages[13],
        ),
        // Part 4
        StoryPage(
          text:
              'Parte 4: Ang Halimaw nga Isda\n\nNaghiwat sang matahom nga kasal kanday Lam-ang kag Ines. Masadya ang tanan.',
          imageAsset: _lamAngImages[14],
        ),
        StoryPage(
          text:
              'Pero may isa pa ka hilikuton si Lam-ang. Kinahanglan niya dakpon ang isa ka pinasahi nga isda sa suba. Kabalo siya nga delikado ini.',
          imageAsset: _lamAngImages[15],
        ),
        StoryPage(
          text:
              '"Kung magsaot ang hagdan kag maguba ang kalan," siling niya kay Ines, "buot silingon may malain nga natabo sa akon."',
          imageAsset: _lamAngImages[16],
        ),
        StoryPage(
          text:
              'Nagdayb si Lam-ang sa tubig. Gulpi lang, ginkaon siya sang isa ka higante nga halimaw nga isda nga ginatawag Berkakan!',
          imageAsset: _lamAngImages[17],
        ),
        StoryPage(
          text:
              'Sa balay, nagsaot ang hagdan kag naguba ang kalan. Naghibi si Ines. Kabalo siya nga wala na si Lam-ang.',
          imageAsset: _lamAngImages[18],
        ),
        // Part 5
        StoryPage(
          text:
              'Parte 5: Ang Malipayon nga Katapusan\n\nPero nagsiling ang Puti nga Manok, "Indi ka maghibi! Maluwas naton siya!" Nagpangabay sila sa isa ka manugsalom nga kuhaon ang mga tul-an ni Lam-ang sa suba.',
          imageAsset: _lamAngImages[19],
        ),
        StoryPage(
          text:
              'Nagpamalo ang Manok, kag nag-usig ang Ido sa mga tul-an. Naglupad ang mga mahiko nga kislap bisan diin!',
          imageAsset: _lamAngImages[20],
        ),
        StoryPage(
          text:
              'Amat-amat, nagbugtaw si Lam-ang! Buhi na siya liwat! Ginhakos niya sing hugot si Ines.',
          imageAsset: _lamAngImages[21],
        ),
        StoryPage(
          text:
              'Nagkabuhi sing malipayon kanday Lam-ang, Ines, ang Manok, kag ang Ido sa wala katapusan.',
          imageAsset: _lamAngImages[22],
        ),
      ],
    ),
  },
);
