SET FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS `api_award`;
CREATE TABLE `api_award` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `icon` varchar(10) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_award` (`id`,`title`,`icon`,`order`) VALUES (21,'India's Most Trusted Brand','?',1);
INSERT INTO `api_award` (`id`,`title`,`icon`,`order`) VALUES (22,'Best Interior Design Solutions Brand','?',2);
INSERT INTO `api_award` (`id`,`title`,`icon`,`order`) VALUES (23,'Innovative Start-up','?',3);
INSERT INTO `api_award` (`id`,`title`,`icon`,`order`) VALUES (24,'World's Most Innovative Company','?',4);
INSERT INTO `api_award` (`id`,`title`,`icon`,`order`) VALUES (25,'Top 100 Global Companies','?',5);

DROP TABLE IF EXISTS `api_calculator`;
CREATE TABLE `api_calculator` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` varchar(200) NOT NULL,
  `cta` varchar(50) NOT NULL,
  `image` varchar(500) NOT NULL,
  `icon` varchar(10) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_calculator` (`id`,`title`,`description`,`cta`,`image`,`icon`,`order`) VALUES (13,'Full Home Interior','Know the estimate price for your full home interiors','Calculate','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=600&q=80','?',1);
INSERT INTO `api_calculator` (`id`,`title`,`description`,`cta`,`image`,`icon`,`order`) VALUES (14,'Kitchen','Get an approximate costing for your kitchen interior','Calculate','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80','?',2);
INSERT INTO `api_calculator` (`id`,`title`,`description`,`cta`,`image`,`icon`,`order`) VALUES (15,'Wardrobe','Our estimate for your dream wardrobe','Calculate','https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=600&q=80','??',3);

DROP TABLE IF EXISTS `api_catalogitem`;
CREATE TABLE `api_catalogitem` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `kind` varchar(20) NOT NULL,
  `name` varchar(200) NOT NULL,
  `description` varchar(300) NOT NULL,
  `unit_price` int(10) unsigned NOT NULL CHECK (`unit_price` >= 0),
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_catalogitem_kind_8a53d38b` (`kind`)
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (1,'accessory','Soft-close Hinges (set of 4)','Whisper-quiet door closure',2400,0,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (2,'accessory','Tandem Drawer (deep)','Heavy-load smooth slide',4800,1,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (3,'accessory','Cutlery Tray (oak finish)','Anti-bacterial coating',1800,2,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (4,'accessory','Magic Corner Pull-out','Maximise blind-corner storage',12500,3,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (5,'accessory','Tall Pantry Pull-out (6-tier)','Vertical grocery storage',18000,4,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (6,'accessory','Bottle Pull-out','Side-mounted spice rack',3200,5,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (7,'accessory','Profile LED Lighting (per room)','Concealed strip with diffuser',4500,6,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (8,'accessory','Wardrobe Trouser Pull-out','Hangs 6 pairs vertically',3600,7,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (9,'accessory','Wardrobe Tie & Belt Organiser','Wall-mount partitioned tray',2200,8,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (10,'accessory','In-built Wardrobe Safe','Concealed digital locker',9500,9,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (11,'accessory','Wicker Basket (pull-out)','Vegetable / linen storage',2800,10,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (12,'accessory','Glass Shutter Upgrade','Frosted toughened glass',6200,11,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (13,'accessory','Loft Storage Module','Above-cabinet enclosed loft',14500,12,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (14,'accessory','Bedside Charging Drawer','Inbuilt USB-A + USB-C',2900,13,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (15,'accessory','Vanity Dresser Mirror Light','Dimmable warm-white LED',3400,14,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (16,'accessory','Concealed Bin Holder (twin)','Wet + dry segregation',3100,15,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (17,'appliance','Built-in Hob (4-burner)','Auto-ignition, Italian glass top',22000,0,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (18,'appliance','Chimney (90 cm, auto-clean)','1200 m³/hr suction, baffle filter',28000,1,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (19,'appliance','Built-in Microwave Oven','32 L, convection + grill',24500,2,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (20,'appliance','Built-in Oven (60 cm)','Multi-function, pyrolytic clean',38000,3,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (21,'appliance','Dishwasher (12-place setting)','Built-under, 6 wash programs',42000,4,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (22,'appliance','Refrigerator (side-by-side, 600L)','Inverter, frost-free',78000,5,1);
INSERT INTO `api_catalogitem` (`id`,`kind`,`name`,`description`,`unit_price`,`order`,`is_active`) VALUES (23,'appliance','Under-counter RO Water Purifier','8L tank, mineraliser cartridge',16500,6,1);

DROP TABLE IF EXISTS `api_chatbotquickreply`;
CREATE TABLE `api_chatbotquickreply` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `label` varchar(80) NOT NULL,
  `response_text` longtext NOT NULL,
  `link_url` varchar(255) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_chatbotquickreply` (`id`,`label`,`response_text`,`link_url`,`order`,`is_active`) VALUES (6,'? Full Home Interior','Our full home interiors start at ?3.62L for 1 BHK with a 45-day delivery guarantee. Want me to book a free consultation for you?','',1,1);
INSERT INTO `api_chatbotquickreply` (`id`,`label`,`response_text`,`link_url`,`order`,`is_active`) VALUES (7,'? Modular Kitchen','Modular kitchens from ?1.7L* with 750+ design options! Our experts match your style and budget. Shall I show you designs?','/design-ideas/modular-kitchen',2,1);
INSERT INTO `api_chatbotquickreply` (`id`,`label`,`response_text`,`link_url`,`order`,`is_active`) VALUES (8,'?? Wardrobe Design','Custom wardrobes from ?8,000/running ft — we maximise every inch. Want to explore wardrobe designs?','/design-ideas/wardrobe',3,1);
INSERT INTO `api_chatbotquickreply` (`id`,`label`,`response_text`,`link_url`,`order`,`is_active`) VALUES (9,'? Get Price Estimate','Get an instant price estimate using our smart calculator. Choose room type, material & city in seconds! ?','/estimate',4,1);
INSERT INTO `api_chatbotquickreply` (`id`,`label`,`response_text`,`link_url`,`order`,`is_active`) VALUES (10,'? Book Consultation','Great choice! A free 30-min consultation with our top designer — no commitment. Let me set it up for you! ?','/contact',5,1);

DROP TABLE IF EXISTS `api_chatbotsettings`;
CREATE TABLE `api_chatbotsettings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `bot_name` varchar(60) NOT NULL,
  `bot_tagline` varchar(80) NOT NULL,
  `welcome_message` longtext NOT NULL,
  `fallback_response` longtext NOT NULL,
  `whatsapp_number` varchar(20) NOT NULL,
  `whatsapp_message` varchar(300) NOT NULL,
  `is_enabled` tinyint(1) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_chatbotsettings` (`id`,`bot_name`,`bot_tagline`,`welcome_message`,`fallback_response`,`whatsapp_number`,`whatsapp_message`,`is_enabled`,`updated_at`) VALUES (1,'Furno Assistant','AI-powered · replies instantly','Hi there! ? I'm Furno, your personal design assistant. What can I help you with today?','Thanks for your message! Our design team will get back within 2 hours. For instant help, WhatsApp us! ?','918045678901','Hi! I'm interested in interior design services from FurnoTech. Can you help me?',1,'2026-05-25 17:21:58.980977');

DROP TABLE IF EXISTS `api_city`;
CREATE TABLE `api_city` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `tier` varchar(10) NOT NULL,
  `active` tinyint(1) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (31,'Bengaluru','bengaluru','tier1',1,1);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (32,'Mumbai','mumbai','tier1',1,2);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (33,'Delhi','delhi','tier1',1,3);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (34,'Hyderabad','hyderabad','tier1',1,4);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (35,'Chennai','chennai','tier1',1,5);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (36,'Pune','pune','tier1',1,6);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (37,'Gurugram','gurugram','tier1',1,7);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (38,'Noida','noida','tier2',1,8);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (39,'Kolkata','kolkata','tier1',1,9);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (40,'Ahmedabad','ahmedabad','tier1',1,10);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (41,'Jaipur','jaipur','tier2',1,11);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (42,'Kochi','kochi','tier2',1,12);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (43,'Chandigarh','chandigarh','tier2',1,13);
INSERT INTO `api_city` (`id`,`name`,`slug`,`tier`,`active`,`order`) VALUES (44,'Lucknow','lucknow','tier2',1,14);

DROP TABLE IF EXISTS `api_contactmessage`;
CREATE TABLE `api_contactmessage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `email` varchar(254) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `city` varchar(100) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `message` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `api_contactmessage_user_id_dea89720_fk_users_id` (`user_id`),
  CONSTRAINT `api_contactmessage_user_id_dea89720_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_contactmessage` (`id`,`name`,`email`,`phone`,`city`,`subject`,`message`,`created_at`,`user_id`) VALUES (1,'Samir Ganesh Watgule','sameer2004watgule@gmail.com','8208967150','Nagpur','General Enquiry','dsdsdfsdfsdfsdfsdfsdfsdfsd','2026-05-15 11:22:07.817139',NULL);
INSERT INTO `api_contactmessage` (`id`,`name`,`email`,`phone`,`city`,`subject`,`message`,`created_at`,`user_id`) VALUES (2,'QA Test User','qa@test.com','9876543210','Bengaluru','Other','This is a QA test message','2026-05-19 16:32:24.884932',NULL);
INSERT INTO `api_contactmessage` (`id`,`name`,`email`,`phone`,`city`,`subject`,`message`,`created_at`,`user_id`) VALUES (3,'QA Tester','qa@test.com','9876543210','Bengaluru','Design Consultation','QA automated test message','2026-05-19 16:52:39.086514',NULL);

DROP TABLE IF EXISTS `api_deliveredhome`;
CREATE TABLE `api_deliveredhome` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `location` varchar(100) NOT NULL,
  `city` varchar(100) NOT NULL,
  `image` varchar(500) NOT NULL,
  `cover_image` varchar(500) NOT NULL,
  `style` varchar(100) NOT NULL,
  `bhk_type` varchar(20) NOT NULL,
  `area_sqft` int(10) unsigned NOT NULL CHECK (`area_sqft` >= 0),
  `budget_min` int(10) unsigned NOT NULL CHECK (`budget_min` >= 0),
  `budget_max` int(10) unsigned NOT NULL CHECK (`budget_max` >= 0),
  `completed_date` date NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_deliveredhome` (`id`,`title`,`location`,`city`,`image`,`cover_image`,`style`,`bhk_type`,`area_sqft`,`budget_min`,`budget_max`,`completed_date`) VALUES (25,'Modern 4 BHK Penthouse','Bengaluru','Bengaluru','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&q=80','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&q=80','Contemporary','4 BHK',2800,32,40,'2025-11-15');
INSERT INTO `api_deliveredhome` (`id`,`title`,`location`,`city`,`image`,`cover_image`,`style`,`bhk_type`,`area_sqft`,`budget_min`,`budget_max`,`completed_date`) VALUES (26,'Contemporary 4 BHK Penthouse','Noida','Noida','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=600&q=80','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=600&q=80','Modern','4 BHK',3100,38,48,'2025-10-02');
INSERT INTO `api_deliveredhome` (`id`,`title`,`location`,`city`,`image`,`cover_image`,`style`,`bhk_type`,`area_sqft`,`budget_min`,`budget_max`,`completed_date`) VALUES (27,'Elegant 2 BHK Flat','Mumbai','Mumbai','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80','Elegant','2 BHK',950,12,16,'2025-12-20');
INSERT INTO `api_deliveredhome` (`id`,`title`,`location`,`city`,`image`,`cover_image`,`style`,`bhk_type`,`area_sqft`,`budget_min`,`budget_max`,`completed_date`) VALUES (28,'Contemporary 3 BHK House','Gurugram','Gurugram','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=600&q=80','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=600&q=80','Contemporary','3 BHK',1650,18,24,'2026-01-10');
INSERT INTO `api_deliveredhome` (`id`,`title`,`location`,`city`,`image`,`cover_image`,`style`,`bhk_type`,`area_sqft`,`budget_min`,`budget_max`,`completed_date`) VALUES (29,'Minimalist 3 BHK Flat','Ahmedabad','Ahmedabad','https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&q=80','https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&q=80','Minimalist','3 BHK',1420,14,18,'2025-09-05');
INSERT INTO `api_deliveredhome` (`id`,`title`,`location`,`city`,`image`,`cover_image`,`style`,`bhk_type`,`area_sqft`,`budget_min`,`budget_max`,`completed_date`) VALUES (30,'Rustic 3 BHK Home','Bengaluru','Bengaluru','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80','Rustic','3 BHK',1800,20,26,'2026-02-28');

DROP TABLE IF EXISTS `api_design`;
CREATE TABLE `api_design` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(300) NOT NULL,
  `style` varchar(100) NOT NULL,
  `image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `category_slug` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  `price_starting_from` int(10) unsigned NOT NULL CHECK (`price_starting_from` >= 0),
  `size` varchar(10) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `trending` tinyint(1) NOT NULL,
  `show_on_homepage` tinyint(1) NOT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`tags`)),
  PRIMARY KEY (`id`),
  KEY `api_design_category_slug_8383af05` (`category_slug`),
  KEY `api_design_slug_c098f12e` (`slug`),
  KEY `api_design_category_id_325c30fc_fk_api_designcategory_id` (`category_id`),
  KEY `api_design_show_on_homepage_05a969ad` (`show_on_homepage`),
  KEY `api_design_style_18fc35a3` (`style`),
  KEY `api_design_trending_f8346e9f` (`trending`),
  CONSTRAINT `api_design_category_id_325c30fc_fk_api_designcategory_id` FOREIGN KEY (`category_id`) REFERENCES `api_designcategory` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=65 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (52,'Elegant L-shaped Modular Kitchen in Walnut Finish','Contemporary','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500&q=80',1,'modular-kitchen','Floor-to-ceiling walnut veneer cabinets with soft-close drawers and integrated appliances for a seamless, clutter-free cooking experience.',175000,'tall','elegant-l-shaped-modular-kitchen',1,1,21,'["L-Shaped", "Walnut Finish", "Contemporary"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (53,'Minimalist Living Room with Accent Wall','Minimalist','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=500&q=80',2,'living-room','A serene sanctuary featuring a textured lime-wash accent wall, low-profile seating, and curated art for understated everyday elegance.',145000,'md','minimalist-living-room-accent-wall',1,1,22,'["Minimalist", "Accent Wall", "Neutral Tones"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (54,'Cozy Master Bedroom with Upholstered Headboard','Modern','https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=500&q=80',3,'master-bedroom','Channel-tufted velvet headboard paired with ambient bedside lighting creates a warm, indulgent hotel-inspired retreat.',120000,'wide','cozy-master-bedroom-upholstered-headboard',1,0,23,'["Upholstered Headboard", "Modern", "King Bed"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (55,'Walk-in Wardrobe with Glass Shutters','Luxury','https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=500&q=80',4,'wardrobe','Custom-built walk-in with glass-front cabinets, pull-out shoe racks, and full-length mirror panels for effortless daily organisation.',95000,'tall','walk-in-wardrobe-glass-shutters',0,0,24,'["Walk-in", "Glass Shutters", "Luxury"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (56,'Contemporary False Ceiling with Cove Lighting','Contemporary','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',5,'false-ceiling','Layered gypsum false ceiling with hidden cove lighting adds architectural depth and dramatic ambiance to the living room.',65000,'md','contemporary-false-ceiling-cove-lighting',0,0,25,'["Cove Lighting", "Gypsum", "Contemporary"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (57,'Compact Home Office with Storage Solutions','Modern','https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=500&q=80',6,'home-office','Smart vertical storage, a floating desk, and warm task lighting transform a compact nook into a highly productive workspace.',85000,'wide','compact-home-office-storage',0,0,26,'["Floating Desk", "Modern", "Storage"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (58,'Scandinavian Living Room with Neutral Palette','Scandinavian','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',7,'living-room','Light oak accents, linen upholstery, and sculptural décor elements define this calm, airy Scandinavian-inspired living retreat.',160000,'md','scandinavian-living-room-neutral-palette',1,0,22,'["Scandinavian", "Oak Accents", "Neutral Palette"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (59,'Vibrant Kids Room with Study Corner','Playful','https://images.unsplash.com/photo-1617806118233-18e1de247200?w=500&q=80',8,'kids-room','Bold primary colours, playful wall murals, and an ergonomic study corner spark creativity, imagination, and focused learning.',95000,'tall','vibrant-kids-room-study-corner',0,0,27,'["Study Corner", "Playful", "Colourful"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (60,'Classic Island Kitchen with Breakfast Bar','Classic','https://images.unsplash.com/photo-1484154218962-a197022b5858?w=500&q=80',9,'modular-kitchen','Shaker-style cabinetry, quartz countertops, and a waterfall island make this kitchen as functional as it is effortlessly beautiful.',210000,'md','classic-island-kitchen-breakfast-bar',1,0,21,'["Island Kitchen", "Classic", "Shaker Style"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (61,'Luxurious Bathroom with Rain Shower','Luxury','https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=500&q=80',10,'bathroom','Italian marble cladding, a freestanding soaking tub, and a rainfall shower head redefine what bathroom luxury truly looks like.',185000,'tall','luxurious-bathroom-rain-shower',1,0,28,'["Rain Shower", "Italian Marble", "Luxury"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (62,'Modern TV Unit with Floating Shelves','Modern','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',11,'tv-unit','Book-matched fluted wood panels, integrated LED strips, and asymmetric floating shelves create a striking entertainment focal wall.',55000,'wide','modern-tv-unit-floating-shelves',0,0,29,'["Floating Unit", "LED Strips", "Fluted Wood"]');
INSERT INTO `api_design` (`id`,`title`,`style`,`image`,`order`,`category_slug`,`description`,`price_starting_from`,`size`,`slug`,`trending`,`show_on_homepage`,`category_id`,`tags`) VALUES (63,'Rustic Dining Room with Wooden Table','Rustic','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',12,'dining-room','Live-edge teak dining table, rattan pendant lights, and terracotta tones bring warm, earthy character to every shared mealtime.',135000,'md','rustic-dining-room-wooden-table',0,0,30,'["Live Edge", "Rustic", "Teak Wood"]');

DROP TABLE IF EXISTS `api_designcategory`;
CREATE TABLE `api_designcategory` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `slug` varchar(100) NOT NULL,
  `label` varchar(200) NOT NULL,
  `hero_desc` longtext NOT NULL,
  `banner_image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=37 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (21,'modular-kitchen','Modular Kitchen','Functional, beautiful kitchens crafted for Indian cooking styles.','',1);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (22,'living-room','Living Room','Create welcoming living spaces that reflect your personality.','',2);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (23,'master-bedroom','Master Bedroom','Serene bedrooms designed for rest and rejuvenation.','',3);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (24,'wardrobe','Wardrobe','Custom wardrobes that maximise storage without compromising style.','',4);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (25,'false-ceiling','False Ceiling','Elegant ceilings that add dimension and light to every room.','',5);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (26,'home-office','Home Office','Productive workspaces designed to inspire focus and creativity.','',6);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (27,'kids-room','Kids Room','Fun, colourful rooms that grow with your children.','',7);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (28,'bathroom','Bathroom','Luxurious bathrooms that turn daily routines into rituals.','',8);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (29,'tv-unit','TV Unit','Stylish entertainment walls that anchor your living space.','',9);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (30,'dining-room','Dining Room','Beautiful dining spaces made for shared meals and memories.','',10);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (31,'pooja-room','Pooja Room','Spaces designed for daily prayer and reflection — compact, serene and culturally rooted.','',0);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (32,'guest-bedroom','Guest Bedroom','Comfortable retreats for visitors — versatile layouts that double as study or hobby rooms.','',0);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (33,'study-room','Study Room','Focused work-from-home and study setups with smart storage and ergonomic furniture.','',0);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (34,'home-bar','Home Bar','Entertain at home with built-in bars, display shelving and cocktail-ready counters.','',0);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (35,'wall-decor','Wall Decor','Statement walls, gallery installations, panelling and texture work for any room.','',0);
INSERT INTO `api_designcategory` (`id`,`slug`,`label`,`hero_desc`,`banner_image`,`order`) VALUES (36,'space-saving','Space Saving','Smart, multi-functional furniture and fold-out concepts for compact homes.','',0);

DROP TABLE IF EXISTS `api_designimage`;
CREATE TABLE `api_designimage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `design_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_designimage_design_id_78f17d3a_fk_api_design_id` (`design_id`),
  CONSTRAINT `api_designimage_design_id_78f17d3a_fk_api_design_id` FOREIGN KEY (`design_id`) REFERENCES `api_design` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=97 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (49,'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1200&q=80',0,52);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (50,'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=1200&q=80',1,52);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (51,'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=1200&q=80',2,52);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (52,'https://images.unsplash.com/photo-1565538810643-b5bdb0dc6e40?w=1200&q=80',3,52);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (53,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',0,53);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (54,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',1,53);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (55,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',2,53);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (56,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&q=80',3,53);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (57,'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80',0,54);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (58,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=1200&q=80',1,54);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (59,'https://images.unsplash.com/photo-1560185007-cde436f6a4d0?w=1200&q=80',2,54);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (60,'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=1200&q=80',3,54);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (61,'https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=1200&q=80',0,55);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (62,'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1200&q=80',1,55);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (63,'https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=1200&q=80',2,55);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (64,'https://images.unsplash.com/photo-1605512358450-33c09e9f8b8b?w=1200&q=80',3,55);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (65,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',0,56);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (66,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',1,56);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (67,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',2,56);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (68,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',3,56);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (69,'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1200&q=80',0,57);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (70,'https://images.unsplash.com/photo-1593640408182-31c70c8268f5?w=1200&q=80',1,57);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (71,'https://images.unsplash.com/photo-1524758631624-e2822e304c36?w=1200&q=80',2,57);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (72,'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80',3,57);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (73,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',0,58);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (74,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',1,58);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (75,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',2,58);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (76,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80',3,58);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (77,'https://images.unsplash.com/photo-1617806118233-18e1de247200?w=1200&q=80',0,59);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (78,'https://images.unsplash.com/photo-1596870230751-ebdfce98ec42?w=1200&q=80',1,59);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (79,'https://images.unsplash.com/photo-1555252333-9f8e92e65df9?w=1200&q=80',2,59);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (80,'https://images.unsplash.com/photo-1540518614846-7eded433c457?w=1200&q=80',3,59);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (81,'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=1200&q=80',0,60);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (82,'https://images.unsplash.com/photo-1556909190-8f8c10c2a9a5?w=1200&q=80',1,60);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (83,'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1200&q=80',2,60);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (84,'https://images.unsplash.com/photo-1565538810643-b5bdb0dc6e40?w=1200&q=80',3,60);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (85,'https://images.unsplash.com/photo-1552321554-5fefe8c9ef14?w=1200&q=80',0,61);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (86,'https://images.unsplash.com/photo-1552320788-b71fbb44f3e7?w=1200&q=80',1,61);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (87,'https://images.unsplash.com/photo-1620626011761-996317702782?w=1200&q=80',2,61);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (88,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',3,61);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (89,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&q=80',0,62);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (90,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',1,62);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (91,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',2,62);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (92,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',3,62);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (93,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',0,63);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (94,'https://images.unsplash.com/photo-1600489000022-c2086d79f9d4?w=1200&q=80',1,63);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (95,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',2,63);
INSERT INTO `api_designimage` (`id`,`image`,`order`,`design_id`) VALUES (96,'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80',3,63);

DROP TABLE IF EXISTS `api_designprocessstep`;
CREATE TABLE `api_designprocessstep` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(120) NOT NULL,
  `body` longtext NOT NULL,
  `image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_designprocessstep` (`id`,`title`,`body`,`image`,`order`,`is_active`) VALUES (1,'Plan & Design','We start by understanding your space, lifestyle and storage needs. Our designers walk through layout options, suggest the right materials, and lock the floor plan with you.','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=900&q=80',0,1);
INSERT INTO `api_designprocessstep` (`id`,`title`,`body`,`image`,`order`,`is_active`) VALUES (2,'Select & Finalise','Pick finishes, hardware and add-on accessories. We share a transparent cost breakdown so you know exactly what’s included before signing off.','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=900&q=80',1,1);
INSERT INTO `api_designprocessstep` (`id`,`title`,`body`,`image`,`order`,`is_active`) VALUES (3,'Manufacture, Install & Support','Your interiors are precision-built in our factory, installed by a vetted team, and backed by a 10-year warranty plus ongoing post-installation support.','https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=900&q=80',2,1);

DROP TABLE IF EXISTS `api_designspec`;
CREATE TABLE `api_designspec` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key` varchar(100) NOT NULL,
  `value` varchar(300) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `design_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_designspec_design_id_fd16950f_fk_api_design_id` (`design_id`),
  CONSTRAINT `api_designspec_design_id_fd16950f_fk_api_design_id` FOREIGN KEY (`design_id`) REFERENCES `api_design` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (78,'Layout','L-Shaped Kitchen',0,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (79,'Dimensions','12×10 feet',1,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (80,'Style','Contemporary',2,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (81,'Color','Walnut Brown',3,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (82,'Shutter Finish','Veneer in Matte Finish',4,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (83,'Countertop Material','Engineered Quartz',5,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (84,'Material','Veneer',6,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (85,'Finish','Matte',7,52);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (86,'Layout','Open Plan Living',0,53);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (87,'Dimensions','16×14 feet',1,53);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (88,'Style','Minimalist',2,53);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (89,'Color','Warm White + Sage',3,53);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (90,'Material','MDF + Lime Plaster',4,53);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (91,'Finish','Matte',5,53);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (92,'Layout','Master Bedroom',0,54);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (93,'Dimensions','14×12 feet',1,54);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (94,'Style','Modern',2,54);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (95,'Color','Deep Teal + Gold',3,54);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (96,'Material','Velvet + Lacquered MDF',4,54);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (97,'Finish','Semi-Gloss',5,54);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (98,'Layout','Walk-in Wardrobe',0,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (99,'Dimensions','10×8 feet',1,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (100,'Style','Luxury',2,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (101,'Color','Pearl White',3,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (102,'Shutter Finish','Frosted Glass Panels',4,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (103,'Material','HDHMR Board',5,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (104,'Finish','High Gloss',6,55);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (105,'Layout','Living Room Ceiling',0,56);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (106,'Dimensions','18×14 feet',1,56);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (107,'Style','Contemporary',2,56);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (108,'Color','Arctic White',3,56);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (109,'Material','Gypsum Board + POP',4,56);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (110,'Finish','Smooth Matte',5,56);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (111,'Layout','Home Office Nook',0,57);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (112,'Dimensions','10×9 feet',1,57);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (113,'Style','Modern',2,57);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (114,'Color','Charcoal + Warm Oak',3,57);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (115,'Material','Plywood + Laminate',4,57);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (116,'Finish','Matte',5,57);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (117,'Layout','Living + Dining',0,58);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (118,'Dimensions','20×16 feet',1,58);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (119,'Style','Scandinavian',2,58);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (120,'Color','Off-White + Light Oak',3,58);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (121,'Material','Solid Oak + Linen',4,58);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (122,'Finish','Natural Oil',5,58);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (123,'Layout','Kids Bedroom',0,59);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (124,'Dimensions','12×10 feet',1,59);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (125,'Style','Playful',2,59);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (126,'Color','Primary Colours',3,59);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (127,'Material','Anti-scratch Laminate',4,59);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (128,'Finish','Matte',5,59);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (129,'Layout','Island Kitchen',0,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (130,'Dimensions','14×12 feet',1,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (131,'Style','Classic',2,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (132,'Color','Ivory White',3,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (133,'Shutter Finish','Shaker Style Laminate',4,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (134,'Countertop Material','Quartz Waterfall Edge',5,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (135,'Material','HDHMR Board',6,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (136,'Finish','Matte',7,60);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (137,'Layout','Master Bathroom',0,61);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (138,'Dimensions','10×8 feet',1,61);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (139,'Style','Luxury',2,61);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (140,'Color','Carrara White + Gold',3,61);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (141,'Material','Italian Marble',4,61);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (142,'Finish','Polished',5,61);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (143,'Layout','Living Room Feature Wall',0,62);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (144,'Dimensions','12×9 feet',1,62);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (145,'Style','Modern',2,62);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (146,'Color','Charcoal + Natural Oak',3,62);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (147,'Material','Plywood + Veneer',4,62);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (148,'Finish','Matte',5,62);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (149,'Layout','Dining Area',0,63);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (150,'Dimensions','14×12 feet',1,63);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (151,'Style','Rustic',2,63);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (152,'Color','Warm Teak + Terracotta',3,63);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (153,'Material','Solid Teak Wood',4,63);
INSERT INTO `api_designspec` (`id`,`key`,`value`,`order`,`design_id`) VALUES (154,'Finish','Oil Rubbed',5,63);

DROP TABLE IF EXISTS `api_designsubcategory`;
CREATE TABLE `api_designsubcategory` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `label` varchar(100) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `category_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_designsubcategor_category_id_1bfcdd39_fk_api_desig` (`category_id`),
  CONSTRAINT `api_designsubcategor_category_id_1bfcdd39_fk_api_desig` FOREIGN KEY (`category_id`) REFERENCES `api_designcategory` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=127 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (85,'L-Shaped',1,21);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (86,'U-Shaped',2,21);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (87,'Straight',3,21);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (88,'Parallel',4,21);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (89,'Island Kitchen',5,21);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (90,'TV Unit',1,22);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (91,'Sofa & Seating',2,22);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (92,'False Ceiling',3,22);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (93,'Wall Panels',4,22);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (94,'Open Shelves',5,22);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (95,'Wardrobe',1,23);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (96,'Bed & Headboard',2,23);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (97,'Study Nook',3,23);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (98,'Dressing Area',4,23);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (99,'Sliding Door',1,24);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (100,'Hinged Door',2,24);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (101,'Walk-in',3,24);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (102,'Corner Wardrobe',4,24);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (103,'Gypsum',1,25);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (104,'POP',2,25);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (105,'Cove Lighting',3,25);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (106,'Tray Ceiling',4,25);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (107,'Study Table',1,26);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (108,'Bookshelf',2,26);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (109,'Ergonomic Setup',3,26);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (110,'Dual Monitor Setup',4,26);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (111,'Study Corner',1,27);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (112,'Bunk Bed',2,27);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (113,'Play Zone',3,27);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (114,'Storage Wall',4,27);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (115,'Vanity Unit',1,28);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (116,'Rain Shower',2,28);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (117,'Bathtub',3,28);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (118,'Compact Bathroom',4,28);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (119,'Floating Unit',1,29);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (120,'Full Wall',2,29);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (121,'With Storage',3,29);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (122,'Backlit Panel',4,29);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (123,'Dining Table',1,30);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (124,'Crockery Unit',2,30);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (125,'Bar Counter',3,30);
INSERT INTO `api_designsubcategory` (`id`,`label`,`order`,`category_id`) VALUES (126,'Open Plan',4,30);

DROP TABLE IF EXISTS `api_estimateconfig`;
CREATE TABLE `api_estimateconfig` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calc_type` varchar(20) NOT NULL,
  `package_tier` varchar(20) NOT NULL,
  `rate_per_unit` int(10) unsigned NOT NULL CHECK (`rate_per_unit` >= 0),
  `unit_label` varchar(30) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_estimateconfig_calc_type_package_tier_5ffa5b02_uniq` (`calc_type`,`package_tier`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (10,'full_home','essential',1800,'sqft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (11,'full_home','comfort',2500,'sqft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (12,'full_home','luxury',3800,'sqft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (13,'kitchen','essential',12000,'running ft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (14,'kitchen','comfort',18000,'running ft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (15,'kitchen','luxury',28000,'running ft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (16,'wardrobe','essential',9000,'running ft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (17,'wardrobe','comfort',14000,'running ft');
INSERT INTO `api_estimateconfig` (`id`,`calc_type`,`package_tier`,`rate_per_unit`,`unit_label`) VALUES (18,'wardrobe','luxury',22000,'running ft');

DROP TABLE IF EXISTS `api_faq`;
CREATE TABLE `api_faq` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `question` varchar(400) NOT NULL,
  `answer` longtext NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `page` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_faq` (`id`,`question`,`answer`,`order`,`page`) VALUES (25,'Why do I need an interior designer?','An interior designer is like a film director for your home. They gauge your needs and tastes to deliver your dream home. They assist you in getting custom-designed pieces that fit perfectly into your beautiful vision. From raw materials to finished products, they take care of everything! You can visit a FurnoTech Experience Centre or fill out the consultation form.',1,'home');
INSERT INTO `api_faq` (`id`,`question`,`answer`,`order`,`page`) VALUES (26,'Why is FurnoTech perfect for your home interior design?','FurnoTech is the perfect partner who can build your home interiors just the way you want! Our design experts customize designs as per your needs. We incorporate advanced technology into our modular solutions to create flawless interiors and expedite the process of making your dream home a reality.',2,'home');
INSERT INTO `api_faq` (`id`,`question`,`answer`,`order`,`page`) VALUES (27,'What services are included under home interior design?','We are a one-stop destination for interior design. We take care of design, delivery and installation. Our end-to-end services include modular interiors, false ceilings, civil work, painting, electrical work, plumbing services, flooring and tiling. Whether you want to design your new space or renovate, we've got you covered.',3,'home');
INSERT INTO `api_faq` (`id`,`question`,`answer`,`order`,`page`) VALUES (28,'How much does home interiors cost?','The cost varies as per home size, materials and scope of work. Basic costs: 1 BHK — Starting at ?3.62L*, 2 BHK — Starting at ?4.52L*, 3 BHK — Starting at ?5.57L*, 4 BHK — Starting at ?6.33L*, Modular Kitchens — Starting at ?1.7L*. These include only modular interiors for new homes.',4,'home');
INSERT INTO `api_faq` (`id`,`question`,`answer`,`order`,`page`) VALUES (29,'What will be the timelines for my project completion?','We deliver our 45-day Move-in Guarantee for modular solutions. For full home interiors, we take 90 days. However, timelines may vary based on material availability, customer feedback, design approvals, and site readiness.',5,'home');
INSERT INTO `api_faq` (`id`,`question`,`answer`,`order`,`page`) VALUES (30,'What are the trending interior design styles?','1. Bohemian Style 2. Modern Style 3. Colonial Style 4. Indian Traditional 5. Art Deco Style 6. Industrial Interior Design 7. Minimalist Interior Design 8. Scandinavian Interior Design',6,'home');

DROP TABLE IF EXISTS `api_footerlink`;
CREATE TABLE `api_footerlink` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `section` varchar(20) NOT NULL,
  `label` varchar(150) NOT NULL,
  `url` varchar(300) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_footerlink_section_3524dd2f` (`section`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_footerlink` (`id`,`section`,`label`,`url`,`order`,`is_active`) VALUES (51,'bottom_bar','Privacy Policy','/about',0,1);
INSERT INTO `api_footerlink` (`id`,`section`,`label`,`url`,`order`,`is_active`) VALUES (52,'bottom_bar','Terms of Service','/about',1,1);
INSERT INTO `api_footerlink` (`id`,`section`,`label`,`url`,`order`,`is_active`) VALUES (53,'bottom_bar','Sitemap','/',2,1);

DROP TABLE IF EXISTS `api_heroslide`;
CREATE TABLE `api_heroslide` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `subtitle` longtext NOT NULL,
  `cta` varchar(100) NOT NULL,
  `image` varchar(500) NOT NULL,
  `tag` varchar(50) DEFAULT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_heroslide` (`id`,`title`,`subtitle`,`cta`,`image`,`tag`,`order`) VALUES (16,'Home to beautiful interiors','Get your dream home designed by experts. End-to-end interior solutions with a lifetime warranty.','Book Free Consultation','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1920&q=80',NULL,1);
INSERT INTO `api_heroslide` (`id`,`title`,`subtitle`,`cta`,`image`,`tag`,`order`) VALUES (17,'Want to know how much your kitchen interiors will cost?','Use our smart calculator to get an instant estimate for your modular kitchen.','Calculate Now','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1920&q=80','Price Calculator',2);
INSERT INTO `api_heroslide` (`id`,`title`,`subtitle`,`cta`,`image`,`tag`,`order`) VALUES (18,'Introducing India's first lifetime warranty*','We stand behind the quality of our work. Enjoy peace of mind with our industry-first lifetime warranty on modular products.','Book Free Consultation','https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=1920&q=80','New',3);

DROP TABLE IF EXISTS `api_inspirationimage`;
CREATE TABLE `api_inspirationimage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `tab_id` bigint(20) NOT NULL,
  `show_on_homepage` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_inspirationimage_tab_id_dabf77f4_fk_api_inspirationtab_id` (`tab_id`),
  CONSTRAINT `api_inspirationimage_tab_id_dabf77f4_fk_api_inspirationtab_id` FOREIGN KEY (`tab_id`) REFERENCES `api_inspirationtab` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=211 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (169,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=500&q=80',1,29,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (170,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',2,29,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (171,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',3,29,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (172,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',4,29,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (173,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',5,29,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (174,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500&q=80',6,29,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (175,'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=500&q=80',1,30,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (176,'https://images.unsplash.com/photo-1556909172-54557c7e4fb7?w=500&q=80',2,30,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (177,'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=500&q=80',3,30,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (178,'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500&q=80',4,30,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (179,'https://images.unsplash.com/photo-1556909114-44e3e70034e2?w=500&q=80',5,30,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (180,'https://images.unsplash.com/photo-1507089947368-19c1da9775ae?w=500&q=80',6,30,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (181,'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=500&q=80',1,31,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (182,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=500&q=80',2,31,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (183,'https://images.unsplash.com/photo-1617325247661-675ab4b64ae2?w=500&q=80',3,31,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (184,'https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=500&q=80',4,31,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (185,'https://images.unsplash.com/photo-1522771739-7f97a74f689f?w=500&q=80',5,31,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (186,'https://images.unsplash.com/photo-1560185127-6a93b2dde8da?w=500&q=80',6,31,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (187,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=500&q=80',1,32,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (188,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',2,32,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (189,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',3,32,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (190,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',4,32,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (191,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',5,32,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (192,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500&q=80',6,32,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (193,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=500&q=80',1,33,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (194,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',2,33,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (195,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',3,33,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (196,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',4,33,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (197,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',5,33,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (198,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500&q=80',6,33,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (199,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=500&q=80',1,34,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (200,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',2,34,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (201,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',3,34,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (202,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',4,34,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (203,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',5,34,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (204,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500&q=80',6,34,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (205,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',1,35,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (206,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',2,35,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (207,'https://images.unsplash.com/photo-1618221195710-dd6b41faaea6?w=500&q=80',3,35,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (208,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',4,35,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (209,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500&q=80',5,35,1);
INSERT INTO `api_inspirationimage` (`id`,`image`,`order`,`tab_id`,`show_on_homepage`) VALUES (210,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',6,35,1);

DROP TABLE IF EXISTS `api_inspirationtab`;
CREATE TABLE `api_inspirationtab` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `label` varchar(100) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `label` (`label`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (29,'Living Room',1);
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (30,'Kitchen',2);
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (31,'Master Bedroom',3);
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (32,'Kids Bedroom',4);
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (33,'Guest Bedroom',5);
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (34,'Dining Room',6);
INSERT INTO `api_inspirationtab` (`id`,`label`,`order`) VALUES (35,'False Ceiling',7);

DROP TABLE IF EXISTS `api_lead`;
CREATE TABLE `api_lead` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `city` varchar(100) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `email` varchar(254) NOT NULL,
  `source` varchar(100) NOT NULL,
  `calculator_type` varchar(20) NOT NULL,
  `design_id` bigint(20) DEFAULT NULL,
  `estimated_amount` int(10) unsigned DEFAULT NULL CHECK (`estimated_amount` >= 0),
  `package_selected` varchar(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `pin_code` varchar(10) NOT NULL,
  `customizations` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`customizations`)),
  PRIMARY KEY (`id`),
  KEY `api_lead_design_id_7f87fb11_fk_api_design_id` (`design_id`),
  KEY `api_lead_user_id_4bbb9b8a_fk_users_id` (`user_id`),
  CONSTRAINT `api_lead_design_id_7f87fb11_fk_api_design_id` FOREIGN KEY (`design_id`) REFERENCES `api_design` (`id`),
  CONSTRAINT `api_lead_user_id_4bbb9b8a_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_lead` (`id`,`name`,`phone`,`city`,`created_at`,`email`,`source`,`calculator_type`,`design_id`,`estimated_amount`,`package_selected`,`user_id`,`pin_code`,`customizations`) VALUES (1,'QA Test','9876543210','Bengaluru','2026-05-19 16:57:25.327117','','website','',NULL,NULL,'',NULL,'','{}');
INSERT INTO `api_lead` (`id`,`name`,`phone`,`city`,`created_at`,`email`,`source`,`calculator_type`,`design_id`,`estimated_amount`,`package_selected`,`user_id`,`pin_code`,`customizations`) VALUES (2,'Samir Ganesh Watgule','8208967150','Pune','2026-05-20 03:35:50.144747','sameer2004watgule@gmail.com','website','',NULL,NULL,'',NULL,'','{}');
INSERT INTO `api_lead` (`id`,`name`,`phone`,`city`,`created_at`,`email`,`source`,`calculator_type`,`design_id`,`estimated_amount`,`package_selected`,`user_id`,`pin_code`,`customizations`) VALUES (10,'Harsh Chakravarti','7387208519','','2026-05-29 05:47:34.852794','harshchakravarti77@gmail.com','design_detail','',60,NULL,'',NULL,'','{}');

DROP TABLE IF EXISTS `api_magazinearticle`;
CREATE TABLE `api_magazinearticle` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(300) NOT NULL,
  `author` varchar(100) NOT NULL,
  `author_avatar` varchar(500) NOT NULL,
  `date` varchar(50) NOT NULL,
  `read_time` smallint(5) unsigned NOT NULL CHECK (`read_time` >= 0),
  `category` varchar(100) NOT NULL,
  `image` varchar(500) NOT NULL,
  `excerpt` longtext NOT NULL,
  `featured` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `body` longtext NOT NULL,
  `slug` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_magazinearticle_slug_980fdd2b` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (37,'50+ Bedroom Colours: Single Shades and Colour Combinations for Every Style','Harsha Shankar','https://i.pravatar.cc/48?img=12','April 14, 2026',8,'Bedroom','https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800&q=80','Discover the perfect palette for your bedroom with our curated guide to colour psychology and trending combinations for Indian homes.',1,'2026-05-19 14:16:44.287179','','50-bedroom-colours');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (38,'15+ Marble Pooja Room Designs That Add a WOW Factor to Your Home','Editorial Team','https://i.pravatar.cc/48?img=5','April 10, 2026',5,'Room Ideas','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=600&q=80','Sacred spaces deserve special attention. Explore stunning marble pooja room designs that blend spirituality with modern aesthetics.',0,'2026-05-19 14:16:44.696432','','15-marble-pooja-room-designs');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (39,'PVC Kitchen Cabinets 2026: Moisture-Resistant, Termite-Proof & Modular','Editorial Team','https://i.pravatar.cc/48?img=5','Mar 06, 2026',6,'Kitchen','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80','PVC is the smart choice for Indian kitchens. Learn why moisture resistance and zero maintenance make it the top pick this year.',0,'2026-05-19 14:16:45.107348','','pvc-kitchen-cabinets-2026');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (40,'Vastu for Home: Room-by-Room Guide for Positive Energy Flow','Priya Sharma','https://i.pravatar.cc/48?img=47','Mar 01, 2026',12,'Vastu','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=600&q=80','A practical Vastu guide for modern Indian homes — balancing ancient wisdom with contemporary interior design principles.',0,'2026-05-19 14:16:45.517297','','vastu-for-home-guide');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (41,'25+ Stunning False Ceiling Designs with Recessed Lighting','Design Team','https://i.pravatar.cc/48?img=33','Feb 22, 2026',7,'Room Ideas','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&q=80','Transform your ceilings into architectural statements. Browse the most popular false ceiling trends for Indian homes in 2026.',0,'2026-05-19 14:16:45.925469','','25-false-ceiling-designs');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (42,'How to Choose the Right Colour Palette for Your Interior Design','Ritu Kapoor','https://i.pravatar.cc/48?img=25','Feb 15, 2026',9,'Expert Tips','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80','Our lead designers share the colour rules they swear by — from undertones to accent walls — for cohesive, beautiful interiors.',0,'2026-05-19 14:16:46.416760','','choose-right-colour-palette');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (43,'Top 10 Modular Kitchen Layouts for Indian Homes in 2026','Harsha Shankar','https://i.pravatar.cc/48?img=12','Feb 08, 2026',10,'Kitchen','https://images.unsplash.com/photo-1484154218962-a197022b5858?w=600&q=80','From L-shaped to parallel kitchens, find the ideal layout that maximises your space and suits the way you cook.',0,'2026-05-19 14:16:46.847323','','top-10-modular-kitchen-layouts');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (44,'Small Bedroom Big Style: 30+ Space-Saving Design Ideas','Editorial Team','https://i.pravatar.cc/48?img=5','Jan 30, 2026',6,'Bedroom','https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80','Small spaces, big dreams. Discover clever storage solutions and design tricks that make compact bedrooms feel luxurious.',0,'2026-05-19 14:16:47.368150','','small-bedroom-big-style');
INSERT INTO `api_magazinearticle` (`id`,`title`,`author`,`author_avatar`,`date`,`read_time`,`category`,`image`,`excerpt`,`featured`,`created_at`,`body`,`slug`) VALUES (45,'Balcony Garden Ideas: Transform Your Outdoor Space','Priya Sharma','https://i.pravatar.cc/48?img=47','Jan 20, 2026',5,'Decor','https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&q=80','Turn your balcony into a green sanctuary with these low-maintenance plant ideas and clever space-saving furniture picks.',0,'2026-05-19 14:16:47.851347','','balcony-garden-ideas');

DROP TABLE IF EXISTS `api_navitem`;
CREATE TABLE `api_navitem` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `href` varchar(200) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  `mega_menu` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`mega_menu`)),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_navitem` (`id`,`name`,`href`,`order`,`is_active`,`mega_menu`) VALUES (1,'Design Ideas','/design-ideas',0,1,'{"columns": [{"links": ["Modular Kitchen Designs", "Wardrobe Designs", "Master Bedroom Designs", "Living Room Designs", "Pooja Room Designs", "TV Unit Designs"], "title": "Popular Rooms"}, {"links": ["Kids Room Designs", "Dining Room Designs", "Home Office Designs", "Guest Bedroom Designs", "Study Room Designs", "Home Bar Designs"], "title": "More Spaces"}, {"links": ["Wall Decor Designs", "Space Saving Designs"], "title": "Elements"}], "featured": [{"href": "/design-ideas/modular-kitchen", "name": "Modular Kitchen Designs", "image": "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=300&q=80"}, {"href": "/design-ideas/living-room", "name": "Living Room Designs", "image": "https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=300&q=80"}]}');
INSERT INTO `api_navitem` (`id`,`name`,`href`,`order`,`is_active`,`mega_menu`) VALUES (2,'Projects','/projects',1,1,NULL);
INSERT INTO `api_navitem` (`id`,`name`,`href`,`order`,`is_active`,`mega_menu`) VALUES (3,'Store Locator','/stores',2,1,NULL);
INSERT INTO `api_navitem` (`id`,`name`,`href`,`order`,`is_active`,`mega_menu`) VALUES (4,'Shop','#',3,1,NULL);
INSERT INTO `api_navitem` (`id`,`name`,`href`,`order`,`is_active`,`mega_menu`) VALUES (5,'About Us','/about',4,1,NULL);
INSERT INTO `api_navitem` (`id`,`name`,`href`,`order`,`is_active`,`mega_menu`) VALUES (6,'Contact','/contact',5,1,NULL);

DROP TABLE IF EXISTS `api_offering`;
CREATE TABLE `api_offering` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) NOT NULL,
  `description` varchar(200) NOT NULL,
  `image` varchar(500) NOT NULL,
  `link` varchar(200) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_offering` (`id`,`title`,`description`,`image`,`link`,`order`) VALUES (17,'Modular Interiors','Functional kitchen, wardrobe and storage','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80','/design-ideas/modular-kitchen',1);
INSERT INTO `api_offering` (`id`,`title`,`description`,`image`,`link`,`order`) VALUES (18,'Full Home Interiors','Turnkey interior solutions for your home','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=600&q=80','/design-ideas',2);
INSERT INTO `api_offering` (`id`,`title`,`description`,`image`,`link`,`order`) VALUES (19,'Luxury Interiors','Tailored interiors that redefine elegance','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&q=80','/design-ideas/living-room',3);
INSERT INTO `api_offering` (`id`,`title`,`description`,`image`,`link`,`order`) VALUES (20,'Renovations','Expert solutions to upgrade your home','https://images.unsplash.com/photo-1484154218962-a197022b5858?w=600&q=80','/design-ideas',4);

DROP TABLE IF EXISTS `api_packagegalleryimage`;
CREATE TABLE `api_packagegalleryimage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calc_type` varchar(20) NOT NULL,
  `package_tier` varchar(20) NOT NULL,
  `image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_packagegalleryimage_calc_type_09b9b1f9` (`calc_type`),
  KEY `api_packagegalleryimage_package_tier_ba114dd8` (`package_tier`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (1,'full_home','essential','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1200&q=80',0,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (2,'full_home','essential','https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80',1,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (3,'full_home','essential','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',2,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (4,'full_home','essential','https://images.unsplash.com/photo-1595428774223-ef52624120d2?w=1200&q=80',3,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (5,'full_home','comfort','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',0,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (6,'full_home','comfort','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1200&q=80',1,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (7,'full_home','comfort','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=1200&q=80',2,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (8,'full_home','comfort','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',3,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (9,'full_home','luxury','https://images.unsplash.com/photo-1567538096630-e0c55bd6374c?w=1200&q=80',0,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (10,'full_home','luxury','https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=1200&q=80',1,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (11,'full_home','luxury','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',2,1);
INSERT INTO `api_packagegalleryimage` (`id`,`calc_type`,`package_tier`,`image`,`order`,`is_active`) VALUES (12,'full_home','luxury','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&q=80',3,1);

DROP TABLE IF EXISTS `api_packageroom`;
CREATE TABLE `api_packageroom` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calc_type` varchar(20) NOT NULL,
  `package_tier` varchar(20) NOT NULL,
  `room` varchar(20) NOT NULL,
  `label` varchar(120) NOT NULL,
  `shape` varchar(50) NOT NULL,
  `size` varchar(50) NOT NULL,
  `material` varchar(100) NOT NULL,
  `finish` varchar(100) NOT NULL,
  `finish_options` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`finish_options`)),
  `hardware` varchar(100) NOT NULL,
  `loft_addon` int(10) unsigned NOT NULL CHECK (`loft_addon` >= 0),
  `included_accessories` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`included_accessories`)),
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_packageroom_calc_type_package_tier_room_ca72d2f7_uniq` (`calc_type`,`package_tier`,`room`),
  KEY `api_packageroom_calc_type_6662c4dc` (`calc_type`),
  KEY `api_packageroom_package_tier_8075698b` (`package_tier`),
  KEY `api_packageroom_room_126960b8` (`room`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (1,'full_home','essential','kitchen','Modular Kitchen','Straight','8 ft','HDF-MR Pre-laminated','Matte Laminate','["Matte Laminate", "Glossy Laminate", "Textured Laminate"]','Ebco',25000,'["Cutlery Tray", "Pull-out Basket", "Bottle Pull-out"]',0);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (2,'full_home','essential','wardrobe','Master Wardrobe','','6 ft','HDF-MR Pre-laminated','Matte Laminate','["Matte Laminate", "Glossy Laminate", "Textured Laminate"]','Ebco',25000,'["Standard Drawer", "Hanging Rod", "Shoe Rack"]',1);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (3,'full_home','essential','living','Living Room','','120 sqft','HDF-MR Pre-laminated','Matte Laminate','["Matte Laminate", "Glossy Laminate", "Textured Laminate"]','Ebco',25000,'["TV Unit Storage", "Open Shelves"]',2);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (4,'full_home','essential','bedroom','Master Bedroom','','160 sqft','HDF-MR Pre-laminated','Matte Laminate','["Matte Laminate", "Glossy Laminate", "Textured Laminate"]','Ebco',25000,'["Bedside Drawer", "Storage Bed"]',3);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (5,'full_home','comfort','kitchen','Modular Kitchen','L-Shape','10 ft','BWP Ply','Matte Laminate','["Matte Laminate", "Glossy Acrylic", "Textured Membrane", "High-Gloss Lacquer"]','Hettich',25000,'["Detergent Holder", "Bottle Pull-out", "Tandem Drawer", "Cutlery Cup & Saucer Tray", "Bin Holder"]',4);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (6,'full_home','comfort','wardrobe','Master Wardrobe','','8 ft','BWP Ply','Matte Laminate','["Matte Laminate", "Glossy Acrylic", "Textured Membrane", "High-Gloss Lacquer"]','Hettich',25000,'["Soft-close Drawer", "Pull-out Tie Rack", "Trouser Pull-out", "LED Profile Light"]',5);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (7,'full_home','comfort','living','Living Room','','160 sqft','BWP Ply','Matte Laminate','["Matte Laminate", "Glossy Acrylic", "Textured Membrane", "High-Gloss Lacquer"]','Hettich',25000,'["Wall-mount TV Unit", "Display Shelves", "Bookcase Module", "Concealed LED"]',6);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (8,'full_home','comfort','bedroom','Master Bedroom','','180 sqft','BWP Ply','Matte Laminate','["Matte Laminate", "Glossy Acrylic", "Textured Membrane", "High-Gloss Lacquer"]','Hettich',25000,'["Hydraulic Storage Bed", "Bedside Tables", "Dresser Unit", "Loft Storage"]',7);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (9,'full_home','luxury','kitchen','Modular Kitchen','Island','12 ft','BWP Marine Ply','PU Finish','["PU Finish", "High-Gloss Acrylic", "Natural Veneer", "Lacquered Glass"]','Blum (Austria)',25000,'["Magic Corner", "Tandem Drawer", "Cutlery Cup Tray", "Bottle Pull-out", "Detergent Pull-out", "Bin Holder", "Pantry Pull-out", "Wicker Basket"]',8);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (10,'full_home','luxury','wardrobe','Master Wardrobe','','10 ft','BWP Marine Ply','PU Finish','["PU Finish", "High-Gloss Acrylic", "Natural Veneer", "Lacquered Glass"]','Blum (Austria)',25000,'["Soft-close Drawer", "Vanity Mirror", "Trouser Pull-out", "Tie & Belt Pull-out", "Inbuilt Safe", "Profile LED", "Glass Shutter"]',9);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (11,'full_home','luxury','living','Living Room','','200 sqft','BWP Marine Ply','PU Finish','["PU Finish", "High-Gloss Acrylic", "Natural Veneer", "Lacquered Glass"]','Blum (Austria)',25000,'["Veneer TV Wall", "Display with Spot Lights", "Bar Unit", "Concealed LED Strips", "Glass Cabinet"]',10);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (12,'full_home','luxury','bedroom','Master Bedroom','','220 sqft','BWP Marine Ply','PU Finish','["PU Finish", "High-Gloss Acrylic", "Natural Veneer", "Lacquered Glass"]','Blum (Austria)',25000,'["Hydraulic Storage Bed", "Custom Bedside", "Vanity Dresser", "Walk-in Closet Entry", "Profile LED Wall"]',11);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (13,'kitchen','essential','kitchen','Modular Kitchen','Straight','8 ft','HDF-MR Pre-laminated','Matte Laminate','["Matte Laminate", "Glossy Laminate", "Textured Laminate"]','Ebco',25000,'["Cutlery Tray", "Pull-out Basket", "Bottle Pull-out"]',12);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (14,'kitchen','comfort','kitchen','Modular Kitchen','L-Shape','10 ft','BWP Ply','Matte Laminate','["Matte Laminate", "Glossy Acrylic", "Textured Membrane", "High-Gloss Lacquer"]','Hettich',25000,'["Detergent Holder", "Bottle Pull-out", "Tandem Drawer", "Cutlery Cup & Saucer Tray", "Bin Holder"]',13);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (15,'kitchen','luxury','kitchen','Modular Kitchen','Island','12 ft','BWP Marine Ply','PU Finish','["PU Finish", "High-Gloss Acrylic", "Natural Veneer", "Lacquered Glass"]','Blum (Austria)',25000,'["Magic Corner", "Tandem Drawer", "Cutlery Cup Tray", "Bottle Pull-out", "Detergent Pull-out", "Bin Holder", "Pantry Pull-out", "Wicker Basket"]',14);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (16,'wardrobe','essential','wardrobe','Master Wardrobe','','6 ft','HDF-MR Pre-laminated','Matte Laminate','["Matte Laminate", "Glossy Laminate", "Textured Laminate"]','Ebco',25000,'["Standard Drawer", "Hanging Rod", "Shoe Rack"]',15);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (17,'wardrobe','comfort','wardrobe','Master Wardrobe','','8 ft','BWP Ply','Matte Laminate','["Matte Laminate", "Glossy Acrylic", "Textured Membrane", "High-Gloss Lacquer"]','Hettich',25000,'["Soft-close Drawer", "Pull-out Tie Rack", "Trouser Pull-out", "LED Profile Light"]',16);
INSERT INTO `api_packageroom` (`id`,`calc_type`,`package_tier`,`room`,`label`,`shape`,`size`,`material`,`finish`,`finish_options`,`hardware`,`loft_addon`,`included_accessories`,`order`) VALUES (18,'wardrobe','luxury','wardrobe','Master Wardrobe','','10 ft','BWP Marine Ply','PU Finish','["PU Finish", "High-Gloss Acrylic", "Natural Veneer", "Lacquered Glass"]','Blum (Austria)',25000,'["Soft-close Drawer", "Vanity Mirror", "Trouser Pull-out", "Tie & Belt Pull-out", "Inbuilt Safe", "Profile LED", "Glass Shutter"]',17);

DROP TABLE IF EXISTS `api_processstep`;
CREATE TABLE `api_processstep` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `step` smallint(5) unsigned NOT NULL CHECK (`step` >= 0),
  `title` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `step` (`step`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_processstep` (`id`,`step`,`title`,`description`) VALUES (21,1,'Explore and Plan','Free consultation + instant quote. Visit a FurnoTech Experience Centre or schedule online. Our designers provide detailed costing for your project.');
INSERT INTO `api_processstep` (`id`,`step`,`title`,`description`) VALUES (22,2,'Secure Your Spot','10% booking locks your slot. Confirm by paying a booking amount of 10% of the final quote or ?25,000 (whichever is higher).');
INSERT INTO `api_processstep` (`id`,`step`,`title`,`description`) VALUES (23,3,'Design and Customize','Pick designs, materials & finishes. Choose from a wide array of options to personalize your home. Make interim payments based on project scope.');
INSERT INTO `api_processstep` (`id`,`step`,`title`,`description`) VALUES (24,4,'Bring Your Vision to Life','Experts execute your plan. Kickstart with a 60% cumulative payment. Our experts meticulously execute your planned design with precision.');
INSERT INTO `api_processstep` (`id`,`step`,`title`,`description`) VALUES (25,5,'Enjoy Your New Home','Move in — done in 45 days. Complete the final payment and watch your vision come to life. Crafted to reflect your unique style.');

DROP TABLE IF EXISTS `api_project`;
CREATE TABLE `api_project` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(300) NOT NULL,
  `bhk` varchar(20) NOT NULL,
  `area` varchar(50) NOT NULL,
  `budget` varchar(50) NOT NULL,
  `style` varchar(100) NOT NULL,
  `image` varchar(500) NOT NULL,
  `description` longtext NOT NULL,
  `slug` varchar(200) NOT NULL,
  `show_on_homepage` tinyint(1) NOT NULL,
  `city_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `api_project_slug_971588a0` (`slug`),
  KEY `api_project_city_id_15b9e02a_fk_api_city_id` (`city_id`),
  KEY `api_project_show_on_homepage_a49ebbc6` (`show_on_homepage`),
  KEY `api_project_style_14ac7e7b` (`style`),
  CONSTRAINT `api_project_city_id_15b9e02a_fk_api_city_id` FOREIGN KEY (`city_id`) REFERENCES `api_city` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (38,'Modern 4 BHK with Custom Cabinetry','4 BHK','2400 sq.ft','?35L','Contemporary','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&q=80','','modern-4-bhk-with-custom-cabinetry',1,31);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (39,'Compact 2 BHK Flat with Smart Storage','2 BHK','850 sq.ft','?12L','Modern','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=600&q=80','','compact-2-bhk-flat-with-smart-storage',1,32);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (40,'Elegant 3 BHK with Walk-in Wardrobes','3 BHK','1800 sq.ft','?22L','Classic','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=600&q=80','','elegant-3-bhk-with-walk-in-wardrobes',1,33);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (41,'Scandinavian 3 BHK Apartment','3 BHK','1600 sq.ft','?18L','Scandinavian','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=600&q=80','','scandinavian-3-bhk-apartment',1,34);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (42,'Luxury Villa with Custom Interiors','5 BHK','4500 sq.ft','?75L','Luxury','https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=600&q=80','','luxury-villa-with-custom-interiors',0,37);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (43,'Minimalist 2 BHK with Open Kitchen','2 BHK','950 sq.ft','?10L','Minimalist','https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=600&q=80','','minimalist-2-bhk-with-open-kitchen',0,36);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (44,'Traditional 3 BHK with Pooja Room','3 BHK','1500 sq.ft','?16L','Indian Traditional','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&q=80','','traditional-3-bhk-with-pooja-room',0,35);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (45,'Industrial Loft-Style Studio Apartment','1 BHK','650 sq.ft','?8L','Industrial','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80','','industrial-loft-style-studio-apartment',0,31);
INSERT INTO `api_project` (`id`,`title`,`bhk`,`area`,`budget`,`style`,`image`,`description`,`slug`,`show_on_homepage`,`city_id`) VALUES (46,'Art Deco 4 BHK with Statement Lighting','4 BHK','2200 sq.ft','?45L','Art Deco','https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=600&q=80','','art-deco-4-bhk-with-statement-lighting',0,32);

DROP TABLE IF EXISTS `api_projectimage`;
CREATE TABLE `api_projectimage` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `image` varchar(500) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `project_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_projectimage_project_id_a2268b36_fk_api_project_id` (`project_id`),
  CONSTRAINT `api_projectimage_project_id_a2268b36_fk_api_project_id` FOREIGN KEY (`project_id`) REFERENCES `api_project` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=49 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (13,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',0,38);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (14,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',1,38);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (15,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',2,38);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (16,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',3,38);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (17,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',0,39);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (18,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',1,39);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (19,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',2,39);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (20,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&q=80',3,39);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (21,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',0,40);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (22,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',1,40);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (23,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80',2,40);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (24,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=1200&q=80',3,40);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (25,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',0,41);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (26,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',1,41);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (27,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',2,41);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (28,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80',3,41);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (29,'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=1200&q=80',0,42);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (30,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',1,42);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (31,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',2,42);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (32,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&q=80',3,42);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (33,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80',0,43);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (34,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',1,43);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (35,'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=1200&q=80',2,43);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (36,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',3,43);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (37,'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=1200&q=80',0,44);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (38,'https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=1200&q=80',1,44);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (39,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',2,44);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (40,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',3,44);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (41,'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=1200&q=80',0,45);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (42,'https://images.unsplash.com/photo-1484154218962-a197022b5858?w=1200&q=80',1,45);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (43,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',2,45);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (44,'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=1200&q=80',3,45);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (45,'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=1200&q=80',0,46);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (46,'https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=1200&q=80',1,46);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (47,'https://images.unsplash.com/photo-1600210492493-0946911123ea?w=1200&q=80',2,46);
INSERT INTO `api_projectimage` (`id`,`image`,`order`,`project_id`) VALUES (48,'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=1200&q=80',3,46);

DROP TABLE IF EXISTS `api_review`;
CREATE TABLE `api_review` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `location` varchar(100) NOT NULL,
  `text` longtext NOT NULL,
  `rating` smallint(5) unsigned NOT NULL CHECK (`rating` >= 0),
  `avatar` varchar(500) NOT NULL,
  `project_image` varchar(500) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_review` (`id`,`name`,`location`,`text`,`rating`,`avatar`,`project_image`,`created_at`) VALUES (21,'Rohit Paul & Shveta','Gurugram','Hats off to the entire team at FurnoTech. They finished the project ahead of time and the quality exceeded our expectations. Every room was designed with such precision.',5,'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&q=80','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=400&q=80','2026-05-19 14:16:33.740310');
INSERT INTO `api_review` (`id`,`name`,`location`,`text`,`rating`,`avatar`,`project_image`,`created_at`) VALUES (22,'Swati & Gaurav','Bengaluru','Our experience was delightful thanks to the project managers. The modular kitchen turned out exactly as we imagined. The 3D visualization really helped us decide.',5,'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&q=80','https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&q=80','2026-05-19 14:16:34.150513');
INSERT INTO `api_review` (`id`,`name`,`location`,`text`,`rating`,`avatar`,`project_image`,`created_at`) VALUES (23,'Puja Bhatia','Gurugram','We reached out and they designed the house that we really wanted. The attention to detail was incredible — from the false ceiling to the wardrobe fittings, everything was perfect.',5,'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&q=80','https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=400&q=80','2026-05-19 14:16:34.530779');
INSERT INTO `api_review` (`id`,`name`,`location`,`text`,`rating`,`avatar`,`project_image`,`created_at`) VALUES (24,'Arjun & Meera','Hyderabad','The modular wardrobe and kitchen installations were done flawlessly. The team kept us updated at every step. Absolutely worth the investment for our 3BHK apartment.',4,'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&q=80','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=400&q=80','2026-05-19 14:16:34.969581');
INSERT INTO `api_review` (`id`,`name`,`location`,`text`,`rating`,`avatar`,`project_image`,`created_at`) VALUES (25,'Sneha Kapoor','Mumbai','From the first consultation to the final walkthrough, the experience was seamless. The designer understood our taste perfectly and our flat looks like a magazine cover now.',5,'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&q=80','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=400&q=80','2026-05-19 14:16:35.378872');

DROP TABLE IF EXISTS `api_saveddesign`;
CREATE TABLE `api_saveddesign` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `saved_at` datetime(6) NOT NULL,
  `design_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `api_saveddesign_user_id_design_id_cb051f52_uniq` (`user_id`,`design_id`),
  KEY `api_saveddesign_design_id_2274d1c3_fk_api_design_id` (`design_id`),
  CONSTRAINT `api_saveddesign_design_id_2274d1c3_fk_api_design_id` FOREIGN KEY (`design_id`) REFERENCES `api_design` (`id`),
  CONSTRAINT `api_saveddesign_user_id_76a9ed3e_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `api_savedestimate`;
CREATE TABLE `api_savedestimate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `calculator_type` varchar(20) NOT NULL,
  `form_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`form_data`)),
  `total_estimated_amount` int(10) unsigned NOT NULL CHECK (`total_estimated_amount` >= 0),
  `package_selected` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `api_savedestimate_user_id_4e22ca70_fk_users_id` (`user_id`),
  CONSTRAINT `api_savedestimate_user_id_4e22ca70_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `api_sitesettings`;
CREATE TABLE `api_sitesettings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `company_email` varchar(200) NOT NULL,
  `company_phone` varchar(30) NOT NULL,
  `company_address` longtext NOT NULL,
  `working_hours` varchar(100) NOT NULL,
  `discount_amount` varchar(50) NOT NULL,
  `discount_code` varchar(50) NOT NULL,
  `discount_active` tinyint(1) NOT NULL,
  `social_facebook` varchar(500) NOT NULL,
  `social_instagram` varchar(500) NOT NULL,
  `social_twitter` varchar(500) NOT NULL,
  `social_linkedin` varchar(500) NOT NULL,
  `social_youtube` varchar(500) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `maintenance_mode` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_sitesettings` (`id`,`company_email`,`company_phone`,`company_address`,`working_hours`,`discount_amount`,`discount_code`,`discount_active`,`social_facebook`,`social_instagram`,`social_twitter`,`social_linkedin`,`social_youtube`,`updated_at`,`maintenance_mode`) VALUES (1,'hello@furnotech.in','+91 80 4567 8901','FurnoTech Pvt. Ltd., 100 Feet Road, Indiranagar, Bengaluru - 560038','Mon-Sun: 10 AM - 8 PM','?10,000','FURNO10',1,'https://facebook.com/furnotech','https://instagram.com/furnotech','','https://linkedin.com/company/furnotech','https://youtube.com/@furnotech','2026-05-29 06:11:23.107632',0);

DROP TABLE IF EXISTS `api_store`;
CREATE TABLE `api_store` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `city` varchar(100) NOT NULL,
  `address` longtext NOT NULL,
  `phone` varchar(30) NOT NULL,
  `hours` varchar(100) NOT NULL,
  `image_url` varchar(500) NOT NULL,
  `latitude` double NOT NULL,
  `longitude` double NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_store` (`id`,`name`,`city`,`address`,`phone`,`hours`,`image_url`,`latitude`,`longitude`) VALUES (25,'FurnoTech Experience Centre — Indiranagar','Bengaluru','100 Feet Road, Indiranagar, Bengaluru - 560038','+91 80 4567 8901','Mon-Sun: 10 AM - 8 PM','https://images.unsplash.com/photo-1618219908412-a29a1bb7b86e?w=500&q=80',12.9784,77.6408);
INSERT INTO `api_store` (`id`,`name`,`city`,`address`,`phone`,`hours`,`image_url`,`latitude`,`longitude`) VALUES (26,'FurnoTech Experience Centre — Andheri','Mumbai','Infinity IT Park, Andheri East, Mumbai - 400059','+91 22 4567 8901','Mon-Sun: 10 AM - 8 PM','https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=500&q=80',19.1136,72.8697);
INSERT INTO `api_store` (`id`,`name`,`city`,`address`,`phone`,`hours`,`image_url`,`latitude`,`longitude`) VALUES (27,'FurnoTech Experience Centre — Janakpuri','Delhi','A-3, District Centre, Janakpuri, New Delhi - 110058','+91 11 4567 8901','Mon-Sun: 10 AM - 8 PM','https://images.unsplash.com/photo-1616486338812-3dadae4b4ace?w=500&q=80',28.6289,77.0864);
INSERT INTO `api_store` (`id`,`name`,`city`,`address`,`phone`,`hours`,`image_url`,`latitude`,`longitude`) VALUES (28,'FurnoTech Experience Centre — Gachibowli','Hyderabad','Biodiversity Junction, Gachibowli, Hyderabad - 500032','+91 40 4567 8901','Mon-Sun: 10 AM - 8 PM','https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&q=80',17.44,78.3489);
INSERT INTO `api_store` (`id`,`name`,`city`,`address`,`phone`,`hours`,`image_url`,`latitude`,`longitude`) VALUES (29,'FurnoTech Experience Centre — Hinjewadi','Pune','Blue Ridge SEZ, Hinjewadi Phase 1, Pune - 411057','+91 20 4567 8901','Mon-Sun: 10 AM - 8 PM','https://images.unsplash.com/photo-1600210492493-0946911123ea?w=500&q=80',18.5912,73.7381);
INSERT INTO `api_store` (`id`,`name`,`city`,`address`,`phone`,`hours`,`image_url`,`latitude`,`longitude`) VALUES (30,'FurnoTech Experience Centre — DLF Phase 5','Gurugram','DLF Cyber City, Phase 5, Gurugram - 122011','+91 124 4567 8901','Mon-Sun: 10 AM - 8 PM','https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=500&q=80',28.4745,77.094);

DROP TABLE IF EXISTS `api_teammember`;
CREATE TABLE `api_teammember` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `role` varchar(200) NOT NULL,
  `bio` longtext NOT NULL,
  `image` varchar(500) NOT NULL,
  `linkedin` varchar(500) NOT NULL,
  `years_exp` smallint(5) unsigned NOT NULL CHECK (`years_exp` >= 0),
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_teammember` (`id`,`name`,`role`,`bio`,`image`,`linkedin`,`years_exp`,`order`) VALUES (9,'Ananya Sharma','Head of Design','With 12 years in luxury interiors, Ananya leads our design philosophy — blending Indian aesthetics with global sensibilities.','https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&q=80','',12,1);
INSERT INTO `api_teammember` (`id`,`name`,`role`,`bio`,`image`,`linkedin`,`years_exp`,`order`) VALUES (10,'Rohan Mehta','Chief Technology Officer','Rohan architects our tech platform, ensuring seamless experience from first consultation to final walkthrough.','https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&q=80','',10,2);
INSERT INTO `api_teammember` (`id`,`name`,`role`,`bio`,`image`,`linkedin`,`years_exp`,`order`) VALUES (11,'Priya Krishnan','VP Operations','Priya owns the 45-day promise. Her ops excellence ensures every project is delivered on time without compromise.','https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=300&q=80','',9,3);
INSERT INTO `api_teammember` (`id`,`name`,`role`,`bio`,`image`,`linkedin`,`years_exp`,`order`) VALUES (12,'Siddharth Nair','Lead Architect','An IIT-trained architect, Siddharth brings structural precision to every space-planning challenge our clients face.','https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=300&q=80','',8,4);

DROP TABLE IF EXISTS `api_trendingproduct`;
CREATE TABLE `api_trendingproduct` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `category` varchar(50) NOT NULL,
  `name` varchar(200) NOT NULL,
  `image` varchar(500) NOT NULL,
  `rating` double NOT NULL,
  `reviews` int(10) unsigned NOT NULL CHECK (`reviews` >= 0),
  `price` int(10) unsigned NOT NULL CHECK (`price` >= 0),
  `original_price` int(10) unsigned NOT NULL CHECK (`original_price` >= 0),
  `discount` smallint(5) unsigned NOT NULL CHECK (`discount` >= 0),
  `badge` varchar(50) DEFAULT NULL,
  `badge_variant` varchar(20) DEFAULT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=35 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (28,'BED','Serena Platform Bed','https://images.unsplash.com/photo-1505693416388-ac5ce068fe85?w=600&q=80',4.3,107,74999,91999,18,'FEATURED','gold',1);
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (29,'TABLE','Harmony Dining Table','https://images.unsplash.com/photo-1551298370-9d3d53740c72?w=600&q=80',4.7,42,54999,67999,19,NULL,NULL,2);
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (30,'STORAGE','Zen Open Bookshelf','https://images.unsplash.com/photo-1594620302200-9a762244a156?w=600&q=80',4.5,38,28999,38000,24,'ECO-CERTIFIED','green',3);
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (31,'SOFA','Oslo Sectional Sofa','https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=600&q=80',4.8,74,89999,112999,20,'BESTSELLER','navy',4);
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (32,'CHAIR','Arc Lounge Chair','https://images.unsplash.com/photo-1506439773649-6e0eb8cfb237?w=600&q=80',4.6,29,32999,42999,23,NULL,NULL,5);
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (33,'TABLE','Marble Coffee Table','https://images.unsplash.com/photo-1526057565006-20beab8dd2ed?w=600&q=80',4.4,53,18999,24999,24,NULL,NULL,6);
INSERT INTO `api_trendingproduct` (`id`,`category`,`name`,`image`,`rating`,`reviews`,`price`,`original_price`,`discount`,`badge`,`badge_variant`,`order`) VALUES (34,'WARDROBE','Nordic Sliding Wardrobe','https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=600&q=80',4.9,91,124999,149999,17,'TOP RATED','purple',7);

DROP TABLE IF EXISTS `api_userprofile`;
CREATE TABLE `api_userprofile` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone` varchar(15) NOT NULL,
  `city` varchar(100) NOT NULL,
  `preferred_style` varchar(100) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `api_userprofile_user_id_5a1c1c92_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_userprofile` (`id`,`phone`,`city`,`preferred_style`,`created_at`,`user_id`) VALUES (1,'8208967150','Nagpur','','2026-05-20 05:47:24.428840',21);

DROP TABLE IF EXISTS `api_whychooseusstat`;
CREATE TABLE `api_whychooseusstat` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `icon` varchar(20) NOT NULL,
  `value` varchar(150) NOT NULL,
  `description` varchar(300) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `api_whychooseusstat` (`id`,`icon`,`value`,`description`,`order`) VALUES (21,'??','1 year warranty¹','India's first lifetime warranty on modular products',1);
INSERT INTO `api_whychooseusstat` (`id`,`icon`,`value`,`description`,`order`) VALUES (22,'?','45-day move-in guarantee²','Move into your new home in just 45 days',2);
INSERT INTO `api_whychooseusstat` (`id`,`icon`,`value`,`description`,`order`) VALUES (23,'?','multi-stage quality checks','Rigorous quality control at every stage',3);
INSERT INTO `api_whychooseusstat` (`id`,`icon`,`value`,`description`,`order`) VALUES (24,'?','750+ products','Massive selection of furniture & decor',4);
INSERT INTO `api_whychooseusstat` (`id`,`icon`,`value`,`description`,`order`) VALUES (25,'???','50+ designers','Expert designers to bring your vision to life',5);

DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `action` varchar(20) NOT NULL,
  `target_type` varchar(80) NOT NULL,
  `target_id` varchar(80) NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `ip` char(39) DEFAULT NULL,
  `user_agent` varchar(300) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `actor_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `audit_logs_action_327a0be3` (`action`),
  KEY `audit_logs_target_type_aa6e53ab` (`target_type`),
  KEY `audit_logs_target_id_42c3f081` (`target_id`),
  KEY `audit_logs_created_at_939a9b33` (`created_at`),
  KEY `audit_logs_target__9fc8de_idx` (`target_type`,`target_id`),
  KEY `audit_logs_actor_i_3b0e80_idx` (`actor_id`,`created_at`),
  CONSTRAINT `audit_logs_actor_id_303d1495_fk_users_id` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (1,'update','dealer_credit','8','{"fields": ["credit_limit", "terms_days", "is_active"]}','127.0.0.1','curl/8.12.1','2026-05-11 05:21:57.417380',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (2,'other','dealer_payment','2','{"kind": "dealer_payment_recorded", "dealer": 8, "amount": "2500", "invoice": null}','127.0.0.1','curl/8.12.1','2026-05-11 05:22:02.041726',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (3,'create','category','9','{"name": "Test Category", "description": "", "is_active": true, "sort_order": 0, "parent": null}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36','2026-05-11 08:38:07.774031',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (4,'approve','review','1','{"status": "approved"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36','2026-05-11 17:43:42.482604',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (5,'delete','review','1','{"product_id": 16, "user_id": 7, "status": "approved"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36','2026-05-11 17:50:36.279526',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (6,'approve','review','2','{"status": "approved"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36','2026-05-11 17:51:51.708301',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (7,'create','faq','4','{"question": "Samir is fan of gargi ?", "answer": "Yes he is if not then he is fan of soumya .", "category": "", "sort_order": 0, "is_active": true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 05:59:45.269095',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (8,'update','content_block','6','{"key": "nav_menu", "title": "Navbar Menu Override", "body_md": "", "is_active": true, "data_json": {"groups": [{"label": "Prestino Director Suit Series", "key": "prestino", "columns": [{"heading": "Prestino Director Suit Series", "items": [{"label": "Prestino Director Table", "slug": "desks"}, {"label": "Prestino Storage", "slug": "storage"}, {"label": "Prestino Book Shelf & Full Height", "slug": "storage"}, {"label": "Free Standing Director Table", "slug": "desks"}, {"label": "Manager Table", "slug": "desks"}, {"label": "CEO Table", "slug": "desks"}, {"label": "Chairman Suit", "slug": "sofas"}, {"label": "Modular Computer Table", "slug": "desks"}, {"label": "Conference Table Series", "slug": "tables"}, {"label": "Modular Workstation Series", "slug": "desks"}, {"label": "Modular Cabin Table", "slug": "desks"}, {"label": "Modular Workstation", "slug": "desks"}]}]}, {"label": "Modular Workstation Series", "key": "modular", "columns": [{"heading": "Modular Workstation Series", "items": [{"label": "Modular Cabin Table", "slug": "desks"}, {"label": "Modular Workstation", "slug": "desks"}]}]}, {"label": "Chair Series", "key": "chairs", "columns": [{"heading": "Chair Series", "items": [{"label": "Chairman Chair Series", "slug": "chairs"}, {"label": "Director Chair Series", "slug": "chairs"}, {"label": "Executive Chair Series", "slug": "chairs"}, {"label": "Manager Chair Series", "slug": "chairs"}, {"label": "Director Chair MSH Series", "slug": "chairs"}, {"label": "Director MSH Chair Color Series", "slug": "chairs"}, {"label": "Visitor Chair Series", "slug": "chairs"}, {"label": "Classroom Chair Series", "slug": "chairs"}, {"label": "Institutional Restaurant Chair Series", "slug": "chairs"}, {"label": "Restaurant & Bar Stool Chair Series", "slug": "chairs"}, {"label": "Restaurant & Bar Chair Series", "slug": "chairs"}, {"label": "Auditorium Chair Series", "slug": "chairs"}]}]}, {"label": "Kid Series", "key": "kids", "columns": [{"heading": "Kids Furniture", "items": [{"label": "Kid Furniture Series", "slug": "beds"}, {"label": "Kid Storage Furniture Series", "slug": "storage"}]}]}, {"label": "Hospital Furniture", "key": "hospital", "columns": [{"heading": "Hospital", "items": [{"label": "Hospital Bed Series", "slug": "beds"}, {"label": "Patient Transfer Trolley Series", "slug": "beds"}]}]}, {"label": "Other Series", "key": "others", "columns": [{"heading": "Others", "items": [{"label": "Laboratory Furniture Series", "slug": "storage"}, {"label": "Hostel Furniture Series", "slug": "beds"}, {"label": "Reception Table Series", "slug": "tables"}, {"label": "Waiting Chair Series", "slug": "chairs"}, {"label": "Office Sofa Series", "slug": "sofas"}, {"label": "Steel Furniture Series", "slug": "storage"}, {"label": "Storage Compactor Series", "slug": "storage"}, {"label": "Partition Series", "slug": "storage"}, {"label": "Chair Part & Accessories Series", "slug": "chairs"}, {"label": "Outdoor & Garden Seating", "slug": "outdoor"}, {"label": "Dining Sets", "slug": "dining-sets"}]}]}]}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 07:28:19.258042',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (9,'create','faq','8','{"question": "Is this a test?", "answer": "Initial Answer", "category": "", "sort_order": 0, "is_active": true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:23:43.412497',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (10,'update','faq','8','{"id": 8, "question": "Is this a test?", "answer": "Updated Answer", "category": "", "sort_order": 0, "is_active": true}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:24:42.708246',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (11,'update','content_block','4','{"key": "announcement_bar", "title": "Announcement Bar", "body_md": "", "is_active": true, "data_json": {"text": "Free shipping on orders above Rs.500 - Trusted by 2 Lakh+ happy homes", "phone": "1800-123-4567"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:49:18.725439',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (12,'update','content_block','4','{"key": "announcement_bar", "title": "Announcement Bar", "body_md": "", "is_active": true, "data_json": {"text": "Free shipping on orders above Rs.299 - Trusted by 1 Lakh+ happy homes", "phone": "1800-123-4567"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:50:17.281405',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (13,'update','content_block','4','{"key": "announcement_bar", "title": "Announcement Bar", "body_md": "", "is_active": true, "data_json": {"text": "Free shipping on orders above Rs.299 - Trusted by 1 Lakh+ happy homes", "phone": "1800-123-4567"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:51:17.746566',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (14,'update','content_block','4','{"key": "announcement_bar", "title": "Announcement Bar", "body_md": "", "is_active": true, "data_json": {"text": "Testing CMS update 123"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:51:55.469407',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (15,'update','content_block','4','{"key": "announcement_bar", "title": "Announcement Bar", "body_md": "", "is_active": true, "data_json": {"text": "\\ud83c\\udf89 Free shipping on orders above \\u20b9299 \\u00b7 Trusted by 1 Lakh+ happy homes", "phone": "1800-123-4567"}}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-12 08:57:47.329329',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (16,'create','newsletter_campaign','1','{"subject": "Test Subject", "body_md": "Test Message from Admin Dashboard", "status": "queued"}','127.0.0.1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-13 07:11:49.844082',1);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (17,'update','stock_movement','2','{"stock_level": 8, "delta": 5, "reason": "inbound"}','223.236.99.185','curl/8.12.1','2026-05-13 13:33:24.767812',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (18,'delete','banner','2','{}','152.56.13.60','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-18 06:29:02.788247',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (19,'other','dealer_payment','9','{"kind": "dealer_payment_recorded", "dealer": 15, "amount": "200000", "invoice": null}','152.56.13.60','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-18 08:26:37.990364',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (20,'update','content_block','4','{"key": "announcement_bar", "title": "Announcement Bar", "body_md": "", "is_active": true, "data_json": {"text": "\\ud83c\\udf89 Free shipping on orders above \\u20b92999 \\u00b7 Trusted by 1 Lakh+ happy homes", "phone": "1800-123-4567"}}','223.236.99.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 16:40:27.262415',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (21,'reject','review','3','{"status": "rejected"}','223.236.99.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 16:47:18.710001',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (22,'approve','review','3','{"status": "approved"}','223.236.99.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 16:47:29.071208',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (23,'reject','review','3','{"status": "rejected"}','223.236.99.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 16:47:34.677099',6);
INSERT INTO `audit_logs` (`id`,`action`,`target_type`,`target_id`,`payload`,`ip`,`user_agent`,`created_at`,`actor_id`) VALUES (24,'approve','review','3','{"status": "approved"}','223.236.99.53','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36','2026-05-23 16:47:37.958319',6);

DROP TABLE IF EXISTS `auth_group`;
CREATE TABLE `auth_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `auth_group_permissions`;
CREATE TABLE `auth_group_permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `group_id` int(11) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `auth_permission`;
CREATE TABLE `auth_permission` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int(11) NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=429 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (1,'Can add log entry',1,'add_logentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (2,'Can change log entry',1,'change_logentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (3,'Can delete log entry',1,'delete_logentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (4,'Can view log entry',1,'view_logentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (5,'Can add permission',2,'add_permission');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (6,'Can change permission',2,'change_permission');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (7,'Can delete permission',2,'delete_permission');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (8,'Can view permission',2,'view_permission');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (9,'Can add group',3,'add_group');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (10,'Can change group',3,'change_group');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (11,'Can delete group',3,'delete_group');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (12,'Can view group',3,'view_group');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (13,'Can add content type',4,'add_contenttype');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (14,'Can change content type',4,'change_contenttype');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (15,'Can delete content type',4,'delete_contenttype');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (16,'Can view content type',4,'view_contenttype');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (17,'Can add session',5,'add_session');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (18,'Can change session',5,'change_session');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (19,'Can delete session',5,'delete_session');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (20,'Can view session',5,'view_session');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (21,'Can add Blacklisted Token',6,'add_blacklistedtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (22,'Can change Blacklisted Token',6,'change_blacklistedtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (23,'Can delete Blacklisted Token',6,'delete_blacklistedtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (24,'Can view Blacklisted Token',6,'view_blacklistedtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (25,'Can add Outstanding Token',7,'add_outstandingtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (26,'Can change Outstanding Token',7,'change_outstandingtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (27,'Can delete Outstanding Token',7,'delete_outstandingtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (28,'Can view Outstanding Token',7,'view_outstandingtoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (29,'Can add association',8,'add_association');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (30,'Can change association',8,'change_association');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (31,'Can delete association',8,'delete_association');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (32,'Can view association',8,'view_association');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (33,'Can add code',9,'add_code');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (34,'Can change code',9,'change_code');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (35,'Can delete code',9,'delete_code');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (36,'Can view code',9,'view_code');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (37,'Can add nonce',10,'add_nonce');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (38,'Can change nonce',10,'change_nonce');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (39,'Can delete nonce',10,'delete_nonce');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (40,'Can view nonce',10,'view_nonce');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (41,'Can add user social auth',11,'add_usersocialauth');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (42,'Can change user social auth',11,'change_usersocialauth');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (43,'Can delete user social auth',11,'delete_usersocialauth');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (44,'Can view user social auth',11,'view_usersocialauth');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (45,'Can add partial',12,'add_partial');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (46,'Can change partial',12,'change_partial');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (47,'Can delete partial',12,'delete_partial');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (48,'Can view partial',12,'view_partial');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (49,'Can add user',13,'add_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (50,'Can change user',13,'change_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (51,'Can delete user',13,'delete_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (52,'Can view user',13,'view_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (53,'Can add password reset token',14,'add_passwordresettoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (54,'Can change password reset token',14,'change_passwordresettoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (55,'Can delete password reset token',14,'delete_passwordresettoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (56,'Can view password reset token',14,'view_passwordresettoken');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (57,'Can add email otp',15,'add_emailotp');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (58,'Can change email otp',15,'change_emailotp');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (59,'Can delete email otp',15,'delete_emailotp');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (60,'Can view email otp',15,'view_emailotp');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (61,'Can add category',16,'add_category');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (62,'Can change category',16,'change_category');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (63,'Can delete category',16,'delete_category');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (64,'Can view category',16,'view_category');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (65,'Can add product',17,'add_product');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (66,'Can change product',17,'change_product');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (67,'Can delete product',17,'delete_product');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (68,'Can view product',17,'view_product');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (69,'Can add product media',18,'add_productmedia');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (70,'Can change product media',18,'change_productmedia');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (71,'Can delete product media',18,'delete_productmedia');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (72,'Can view product media',18,'view_productmedia');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (73,'Can add product specification',19,'add_productspecification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (74,'Can change product specification',19,'change_productspecification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (75,'Can delete product specification',19,'delete_productspecification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (76,'Can view product specification',19,'view_productspecification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (77,'Can add product variant',20,'add_productvariant');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (78,'Can change product variant',20,'change_productvariant');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (79,'Can delete product variant',20,'delete_productvariant');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (80,'Can view product variant',20,'view_productvariant');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (81,'Can add delivery rule',21,'add_deliveryrule');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (82,'Can change delivery rule',21,'change_deliveryrule');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (83,'Can delete delivery rule',21,'delete_deliveryrule');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (84,'Can view delivery rule',21,'view_deliveryrule');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (85,'Can add tag',22,'add_tag');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (86,'Can change tag',22,'change_tag');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (87,'Can delete tag',22,'delete_tag');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (88,'Can view tag',22,'view_tag');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (89,'Can add order',23,'add_order');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (90,'Can change order',23,'change_order');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (91,'Can delete order',23,'delete_order');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (92,'Can view order',23,'view_order');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (93,'Can add order item',24,'add_orderitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (94,'Can change order item',24,'change_orderitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (95,'Can delete order item',24,'delete_orderitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (96,'Can view order item',24,'view_orderitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (97,'Can add order return',25,'add_orderreturn');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (98,'Can change order return',25,'change_orderreturn');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (99,'Can delete order return',25,'delete_orderreturn');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (100,'Can view order return',25,'view_orderreturn');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (101,'Can add refund',26,'add_refund');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (102,'Can change refund',26,'change_refund');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (103,'Can delete refund',26,'delete_refund');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (104,'Can view refund',26,'view_refund');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (105,'Can add payment',27,'add_payment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (106,'Can change payment',27,'change_payment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (107,'Can delete payment',27,'delete_payment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (108,'Can view payment',27,'view_payment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (109,'Can add discount',28,'add_discount');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (110,'Can change discount',28,'change_discount');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (111,'Can delete discount',28,'delete_discount');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (112,'Can view discount',28,'view_discount');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (113,'Can add store settings',29,'add_storesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (114,'Can change store settings',29,'change_storesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (115,'Can delete store settings',29,'delete_storesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (116,'Can view store settings',29,'view_storesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (117,'Can add audit log',30,'add_auditlog');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (118,'Can change audit log',30,'change_auditlog');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (119,'Can delete audit log',30,'delete_auditlog');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (120,'Can view audit log',30,'view_auditlog');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (121,'Can add warehouse',31,'add_warehouse');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (122,'Can change warehouse',31,'change_warehouse');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (123,'Can delete warehouse',31,'delete_warehouse');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (124,'Can view warehouse',31,'view_warehouse');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (125,'Can add stock level',32,'add_stocklevel');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (126,'Can change stock level',32,'change_stocklevel');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (127,'Can delete stock level',32,'delete_stocklevel');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (128,'Can view stock level',32,'view_stocklevel');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (129,'Can add stock movement',33,'add_stockmovement');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (130,'Can change stock movement',33,'change_stockmovement');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (131,'Can delete stock movement',33,'delete_stockmovement');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (132,'Can view stock movement',33,'view_stockmovement');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (133,'Can add banner',34,'add_banner');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (134,'Can change banner',34,'change_banner');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (135,'Can delete banner',34,'delete_banner');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (136,'Can view banner',34,'view_banner');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (137,'Can add FAQ',35,'add_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (138,'Can change FAQ',35,'change_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (139,'Can delete FAQ',35,'delete_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (140,'Can view FAQ',35,'view_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (141,'Can add page',36,'add_page');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (142,'Can change page',36,'change_page');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (143,'Can delete page',36,'delete_page');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (144,'Can view page',36,'view_page');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (145,'Can add notification',37,'add_notification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (146,'Can change notification',37,'change_notification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (147,'Can delete notification',37,'delete_notification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (148,'Can view notification',37,'view_notification');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (149,'Can add media asset',38,'add_mediaasset');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (150,'Can change media asset',38,'change_mediaasset');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (151,'Can delete media asset',38,'delete_mediaasset');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (152,'Can view media asset',38,'view_mediaasset');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (153,'Can add invoice counter',39,'add_invoicecounter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (154,'Can change invoice counter',39,'change_invoicecounter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (155,'Can delete invoice counter',39,'delete_invoicecounter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (156,'Can view invoice counter',39,'view_invoicecounter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (157,'Can add invoice',40,'add_invoice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (158,'Can change invoice',40,'change_invoice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (159,'Can delete invoice',40,'delete_invoice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (160,'Can view invoice',40,'view_invoice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (161,'Can add invoice item',41,'add_invoiceitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (162,'Can change invoice item',41,'change_invoiceitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (163,'Can delete invoice item',41,'delete_invoiceitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (164,'Can view invoice item',41,'view_invoiceitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (165,'Can add review',42,'add_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (166,'Can change review',42,'change_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (167,'Can delete review',42,'delete_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (168,'Can view review',42,'view_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (169,'Can add review vote',43,'add_reviewvote');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (170,'Can change review vote',43,'change_reviewvote');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (171,'Can delete review vote',43,'delete_reviewvote');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (172,'Can view review vote',43,'view_reviewvote');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (173,'Can add wishlist item',44,'add_wishlistitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (174,'Can change wishlist item',44,'change_wishlistitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (175,'Can delete wishlist item',44,'delete_wishlistitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (176,'Can view wishlist item',44,'view_wishlistitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (177,'Can add dealer tier',45,'add_dealertier');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (178,'Can change dealer tier',45,'change_dealertier');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (179,'Can delete dealer tier',45,'delete_dealertier');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (180,'Can view dealer tier',45,'view_dealertier');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (181,'Can add negotiated price',46,'add_negotiatedprice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (182,'Can change negotiated price',46,'change_negotiatedprice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (183,'Can delete negotiated price',46,'delete_negotiatedprice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (184,'Can view negotiated price',46,'view_negotiatedprice');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (185,'Can add dealer credit',47,'add_dealercredit');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (186,'Can change dealer credit',47,'change_dealercredit');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (187,'Can delete dealer credit',47,'delete_dealercredit');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (188,'Can view dealer credit',47,'view_dealercredit');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (189,'Can add dealer payment',48,'add_dealerpayment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (190,'Can change dealer payment',48,'change_dealerpayment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (191,'Can delete dealer payment',48,'delete_dealerpayment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (192,'Can view dealer payment',48,'view_dealerpayment');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (193,'Can add coupon',49,'add_coupon');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (194,'Can change coupon',49,'change_coupon');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (195,'Can delete coupon',49,'delete_coupon');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (196,'Can view coupon',49,'view_coupon');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (197,'Can add coupon redemption',50,'add_couponredemption');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (198,'Can change coupon redemption',50,'change_couponredemption');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (199,'Can delete coupon redemption',50,'delete_couponredemption');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (200,'Can view coupon redemption',50,'view_couponredemption');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (201,'Can add shipping zone',51,'add_shippingzone');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (202,'Can change shipping zone',51,'change_shippingzone');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (203,'Can delete shipping zone',51,'delete_shippingzone');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (204,'Can view shipping zone',51,'view_shippingzone');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (205,'Can add dealer wallet',52,'add_dealerwallet');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (206,'Can change dealer wallet',52,'change_dealerwallet');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (207,'Can delete dealer wallet',52,'delete_dealerwallet');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (208,'Can view dealer wallet',52,'view_dealerwallet');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (209,'Can add wallet transaction',53,'add_wallettransaction');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (210,'Can change wallet transaction',53,'change_wallettransaction');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (211,'Can delete wallet transaction',53,'delete_wallettransaction');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (212,'Can view wallet transaction',53,'view_wallettransaction');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (213,'Can add support ticket',54,'add_supportticket');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (214,'Can change support ticket',54,'change_supportticket');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (215,'Can delete support ticket',54,'delete_supportticket');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (216,'Can view support ticket',54,'view_supportticket');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (217,'Can add ticket message',55,'add_ticketmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (218,'Can change ticket message',55,'change_ticketmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (219,'Can delete ticket message',55,'delete_ticketmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (220,'Can view ticket message',55,'view_ticketmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (221,'Can add newsletter subscriber',56,'add_newslettersubscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (222,'Can change newsletter subscriber',56,'change_newslettersubscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (223,'Can delete newsletter subscriber',56,'delete_newslettersubscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (224,'Can view newsletter subscriber',56,'view_newslettersubscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (225,'Can add notification preference',57,'add_notificationpreference');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (226,'Can change notification preference',57,'change_notificationpreference');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (227,'Can delete notification preference',57,'delete_notificationpreference');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (228,'Can view notification preference',57,'view_notificationpreference');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (229,'Can add content block',58,'add_contentblock');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (230,'Can change content block',58,'change_contentblock');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (231,'Can delete content block',58,'delete_contentblock');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (232,'Can view content block',58,'view_contentblock');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (233,'Can add newsletter campaign',59,'add_newslettercampaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (234,'Can change newsletter campaign',59,'change_newslettercampaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (235,'Can delete newsletter campaign',59,'delete_newslettercampaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (236,'Can view newsletter campaign',59,'view_newslettercampaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (237,'Can add user address',60,'add_useraddress');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (238,'Can change user address',60,'change_useraddress');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (239,'Can delete user address',60,'delete_useraddress');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (240,'Can view user address',60,'view_useraddress');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (241,'Can add newsletter',61,'add_newsletter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (242,'Can change newsletter',61,'change_newsletter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (243,'Can delete newsletter',61,'delete_newsletter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (244,'Can view newsletter',61,'view_newsletter');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (245,'Can add subscriber',62,'add_subscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (246,'Can change subscriber',62,'change_subscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (247,'Can delete subscriber',62,'delete_subscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (248,'Can view subscriber',62,'view_subscriber');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (249,'Can add stock alert',63,'add_stockalert');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (250,'Can change stock alert',63,'change_stockalert');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (251,'Can delete stock alert',63,'delete_stockalert');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (252,'Can view stock alert',63,'view_stockalert');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (253,'Can add contact',64,'add_contact');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (254,'Can change contact',64,'change_contact');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (255,'Can delete contact',64,'delete_contact');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (256,'Can view contact',64,'view_contact');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (257,'Can add delivery',65,'add_delivery');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (258,'Can change delivery',65,'change_delivery');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (259,'Can delete delivery',65,'delete_delivery');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (260,'Can view delivery',65,'view_delivery');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (261,'Can add campaign',66,'add_campaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (262,'Can change campaign',66,'change_campaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (263,'Can delete campaign',66,'delete_campaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (264,'Can view campaign',66,'view_campaign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (265,'Can add faq entry',67,'add_faqentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (266,'Can change faq entry',67,'change_faqentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (267,'Can delete faq entry',67,'delete_faqentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (268,'Can view faq entry',67,'view_faqentry');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (269,'Can add site',68,'add_site');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (270,'Can change site',68,'change_site');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (271,'Can delete site',68,'delete_site');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (272,'Can view site',68,'view_site');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (273,'Can add user',69,'add_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (274,'Can change user',69,'change_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (275,'Can delete user',69,'delete_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (276,'Can view user',69,'view_user');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (277,'Can add award',70,'add_award');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (278,'Can change award',70,'change_award');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (279,'Can delete award',70,'delete_award');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (280,'Can view award',70,'view_award');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (281,'Can add calculator',71,'add_calculator');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (282,'Can change calculator',71,'change_calculator');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (283,'Can delete calculator',71,'delete_calculator');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (284,'Can view calculator',71,'view_calculator');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (285,'Can add contact message',72,'add_contactmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (286,'Can change contact message',72,'change_contactmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (287,'Can delete contact message',72,'delete_contactmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (288,'Can view contact message',72,'view_contactmessage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (289,'Can add delivered home',73,'add_deliveredhome');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (290,'Can change delivered home',73,'change_deliveredhome');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (291,'Can delete delivered home',73,'delete_deliveredhome');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (292,'Can view delivered home',73,'view_deliveredhome');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (293,'Can add design',74,'add_design');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (294,'Can change design',74,'change_design');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (295,'Can delete design',74,'delete_design');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (296,'Can view design',74,'view_design');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (297,'Can add faq',75,'add_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (298,'Can change faq',75,'change_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (299,'Can delete faq',75,'delete_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (300,'Can view faq',75,'view_faq');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (301,'Can add hero slide',76,'add_heroslide');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (302,'Can change hero slide',76,'change_heroslide');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (303,'Can delete hero slide',76,'delete_heroslide');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (304,'Can view hero slide',76,'view_heroslide');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (305,'Can add inspiration tab',77,'add_inspirationtab');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (306,'Can change inspiration tab',77,'change_inspirationtab');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (307,'Can delete inspiration tab',77,'delete_inspirationtab');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (308,'Can view inspiration tab',77,'view_inspirationtab');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (309,'Can add lead',78,'add_lead');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (310,'Can change lead',78,'change_lead');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (311,'Can delete lead',78,'delete_lead');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (312,'Can view lead',78,'view_lead');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (313,'Can add magazine article',79,'add_magazinearticle');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (314,'Can change magazine article',79,'change_magazinearticle');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (315,'Can delete magazine article',79,'delete_magazinearticle');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (316,'Can view magazine article',79,'view_magazinearticle');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (317,'Can add offering',80,'add_offering');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (318,'Can change offering',80,'change_offering');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (319,'Can delete offering',80,'delete_offering');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (320,'Can view offering',80,'view_offering');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (321,'Can add process step',81,'add_processstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (322,'Can change process step',81,'change_processstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (323,'Can delete process step',81,'delete_processstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (324,'Can view process step',81,'view_processstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (325,'Can add project',82,'add_project');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (326,'Can change project',82,'change_project');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (327,'Can delete project',82,'delete_project');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (328,'Can view project',82,'view_project');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (329,'Can add review',83,'add_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (330,'Can change review',83,'change_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (331,'Can delete review',83,'delete_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (332,'Can view review',83,'view_review');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (333,'Can add store',84,'add_store');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (334,'Can change store',84,'change_store');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (335,'Can delete store',84,'delete_store');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (336,'Can view store',84,'view_store');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (337,'Can add trending product',85,'add_trendingproduct');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (338,'Can change trending product',85,'change_trendingproduct');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (339,'Can delete trending product',85,'delete_trendingproduct');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (340,'Can view trending product',85,'view_trendingproduct');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (341,'Can add why choose us stat',86,'add_whychooseusstat');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (342,'Can change why choose us stat',86,'change_whychooseusstat');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (343,'Can delete why choose us stat',86,'delete_whychooseusstat');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (344,'Can view why choose us stat',86,'view_whychooseusstat');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (345,'Can add inspiration image',87,'add_inspirationimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (346,'Can change inspiration image',87,'change_inspirationimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (347,'Can delete inspiration image',87,'delete_inspirationimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (348,'Can view inspiration image',87,'view_inspirationimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (349,'Can add project image',88,'add_projectimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (350,'Can change project image',88,'change_projectimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (351,'Can delete project image',88,'delete_projectimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (352,'Can view project image',88,'view_projectimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (353,'Can add city',89,'add_city');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (354,'Can change city',89,'change_city');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (355,'Can delete city',89,'delete_city');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (356,'Can view city',89,'view_city');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (357,'Can add design category',90,'add_designcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (358,'Can change design category',90,'change_designcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (359,'Can delete design category',90,'delete_designcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (360,'Can view design category',90,'view_designcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (361,'Can add Site Settings',91,'add_sitesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (362,'Can change Site Settings',91,'change_sitesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (363,'Can delete Site Settings',91,'delete_sitesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (364,'Can view Site Settings',91,'view_sitesettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (365,'Can add team member',92,'add_teammember');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (366,'Can change team member',92,'change_teammember');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (367,'Can delete team member',92,'delete_teammember');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (368,'Can view team member',92,'view_teammember');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (369,'Can add design image',93,'add_designimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (370,'Can change design image',93,'change_designimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (371,'Can delete design image',93,'delete_designimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (372,'Can view design image',93,'view_designimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (373,'Can add design spec',94,'add_designspec');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (374,'Can change design spec',94,'change_designspec');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (375,'Can delete design spec',94,'delete_designspec');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (376,'Can view design spec',94,'view_designspec');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (377,'Can add design sub category',95,'add_designsubcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (378,'Can change design sub category',95,'change_designsubcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (379,'Can delete design sub category',95,'delete_designsubcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (380,'Can view design sub category',95,'view_designsubcategory');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (381,'Can add Estimate Config',96,'add_estimateconfig');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (382,'Can change Estimate Config',96,'change_estimateconfig');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (383,'Can delete Estimate Config',96,'delete_estimateconfig');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (384,'Can view Estimate Config',96,'view_estimateconfig');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (385,'Can add saved estimate',97,'add_savedestimate');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (386,'Can change saved estimate',97,'change_savedestimate');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (387,'Can delete saved estimate',97,'delete_savedestimate');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (388,'Can view saved estimate',97,'view_savedestimate');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (389,'Can add user profile',98,'add_userprofile');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (390,'Can change user profile',98,'change_userprofile');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (391,'Can delete user profile',98,'delete_userprofile');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (392,'Can view user profile',98,'view_userprofile');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (393,'Can add saved design',99,'add_saveddesign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (394,'Can change saved design',99,'change_saveddesign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (395,'Can delete saved design',99,'delete_saveddesign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (396,'Can view saved design',99,'view_saveddesign');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (397,'Can add nav item',100,'add_navitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (398,'Can change nav item',100,'change_navitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (399,'Can delete nav item',100,'delete_navitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (400,'Can view nav item',100,'view_navitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (401,'Can add footer link',101,'add_footerlink');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (402,'Can change footer link',101,'change_footerlink');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (403,'Can delete footer link',101,'delete_footerlink');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (404,'Can view footer link',101,'view_footerlink');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (405,'Can add catalog item',102,'add_catalogitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (406,'Can change catalog item',102,'change_catalogitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (407,'Can delete catalog item',102,'delete_catalogitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (408,'Can view catalog item',102,'view_catalogitem');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (409,'Can add package gallery image',103,'add_packagegalleryimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (410,'Can change package gallery image',103,'change_packagegalleryimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (411,'Can delete package gallery image',103,'delete_packagegalleryimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (412,'Can view package gallery image',103,'view_packagegalleryimage');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (413,'Can add package room',104,'add_packageroom');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (414,'Can change package room',104,'change_packageroom');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (415,'Can delete package room',104,'delete_packageroom');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (416,'Can view package room',104,'view_packageroom');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (417,'Can add design process step',105,'add_designprocessstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (418,'Can change design process step',105,'change_designprocessstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (419,'Can delete design process step',105,'delete_designprocessstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (420,'Can view design process step',105,'view_designprocessstep');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (421,'Can add Chatbot Quick Reply',106,'add_chatbotquickreply');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (422,'Can change Chatbot Quick Reply',106,'change_chatbotquickreply');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (423,'Can delete Chatbot Quick Reply',106,'delete_chatbotquickreply');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (424,'Can view Chatbot Quick Reply',106,'view_chatbotquickreply');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (425,'Can add Chatbot Settings',107,'add_chatbotsettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (426,'Can change Chatbot Settings',107,'change_chatbotsettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (427,'Can delete Chatbot Settings',107,'delete_chatbotsettings');
INSERT INTO `auth_permission` (`id`,`name`,`content_type_id`,`codename`) VALUES (428,'Can view Chatbot Settings',107,'view_chatbotsettings');

DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `banner_image` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `parent_id` bigint(20) DEFAULT NULL,
  `sort_order` int(10) unsigned NOT NULL CHECK (`sort_order` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `slug` (`slug`),
  KEY `categories_parent_id_fc02df82_fk_categories_id` (`parent_id`),
  CONSTRAINT `categories_parent_id_fc02df82_fk_categories_id` FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (1,'Sofas','sofas','Comfortable sofas and sectionals','2026-05-10 15:58:53.365143',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (2,'Tables','tables','Dining and coffee tables','2026-05-10 15:58:56.019752',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (3,'Chairs','chairs','Office and accent chairs','2026-05-10 15:58:57.339858',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (4,'Beds','beds','Beds and bedroom furniture','2026-05-10 15:58:59.727089',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (5,'Storage','storage','Shelves, wardrobes, and storage','2026-05-10 15:59:00.474391',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (6,'Desks','desks','Work-from-home and study desks','2026-05-10 15:59:02.229890',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (7,'Dining Sets','dining-sets','Complete dining room sets','2026-05-10 15:59:03.783965',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (8,'Outdoor','outdoor','Outdoor and garden furniture','2026-05-10 15:59:04.395392',NULL,1,NULL,0);
INSERT INTO `categories` (`id`,`name`,`slug`,`description`,`created_at`,`banner_image`,`is_active`,`parent_id`,`sort_order`) VALUES (9,'Test Category','test-category','','2026-05-11 08:38:07.632454',NULL,1,NULL,0);

DROP TABLE IF EXISTS `cms_banners`;
CREATE TABLE `cms_banners` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `title` varchar(200) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `image_url` varchar(500) NOT NULL,
  `link_url` varchar(200) NOT NULL,
  `placement` varchar(20) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `sort_order` int(10) unsigned NOT NULL CHECK (`sort_order` >= 0),
  `starts_at` datetime(6) DEFAULT NULL,
  `ends_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cms_banners_placement_53b2b0ec` (`placement`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `cms_banners` (`id`,`title`,`image`,`image_url`,`link_url`,`placement`,`is_active`,`sort_order`,`starts_at`,`ends_at`,`created_at`,`updated_at`) VALUES (1,'Welcome to FurniShop','furnishop/banners/welcome-to-furnishop-1','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258207/furnishop/banners/welcome-to-furnishop-1.jpg','/','home_hero',1,0,NULL,NULL,'2026-05-10 15:58:30.237378','2026-05-20 06:23:27.876973');
INSERT INTO `cms_banners` (`id`,`title`,`image`,`image_url`,`link_url`,`placement`,`is_active`,`sort_order`,`starts_at`,`ends_at`,`created_at`,`updated_at`) VALUES (3,'New Arrival — Modern Sofas','furnishop/banners/new-arrival-modern-sofas-3','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258208/furnishop/banners/new-arrival-modern-sofas-3.jpg','','home_hero',1,1,NULL,NULL,'2026-05-12 06:48:19.743580','2026-05-20 06:23:29.485743');
INSERT INTO `cms_banners` (`id`,`title`,`image`,`image_url`,`link_url`,`placement`,`is_active`,`sort_order`,`starts_at`,`ends_at`,`created_at`,`updated_at`) VALUES (4,'Best Seller — Bath Collection','furnishop/banners/best-seller-bath-collection-4','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258212/furnishop/banners/best-seller-bath-collection-4.jpg','','home_hero',1,2,NULL,NULL,'2026-05-12 06:48:20.257230','2026-05-20 06:23:32.965996');
INSERT INTO `cms_banners` (`id`,`title`,`image`,`image_url`,`link_url`,`placement`,`is_active`,`sort_order`,`starts_at`,`ends_at`,`created_at`,`updated_at`) VALUES (5,'New Arrival - Modern Sofas','furnishop/banners/new-arrival-modern-sofas-5','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258210/furnishop/banners/new-arrival-modern-sofas-5.jpg','','home_hero',1,1,NULL,NULL,'2026-05-12 06:49:16.666608','2026-05-20 06:23:31.139834');
INSERT INTO `cms_banners` (`id`,`title`,`image`,`image_url`,`link_url`,`placement`,`is_active`,`sort_order`,`starts_at`,`ends_at`,`created_at`,`updated_at`) VALUES (6,'Best Seller - Bath Collection','furnishop/banners/best-seller-bath-collection-6','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258213/furnishop/banners/best-seller-bath-collection-6.jpg','','home_hero',1,2,NULL,NULL,'2026-05-12 06:49:17.155905','2026-05-20 06:23:34.476121');

DROP TABLE IF EXISTS `cms_content_blocks`;
CREATE TABLE `cms_content_blocks` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `key` varchar(80) NOT NULL,
  `title` varchar(200) NOT NULL,
  `body_md` longtext NOT NULL,
  `data_json` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`data_json`)),
  `is_active` tinyint(1) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `cms_content_blocks` (`id`,`key`,`title`,`body_md`,`data_json`,`is_active`,`updated_at`,`created_at`) VALUES (1,'home_hero_copy','Homepage Hero Copy','','{"eyebrow": "New Arrival - Modern Sofas", "title": "Beautiful Homes", "accent": "Start Here", "desc": "Premium furniture & home essentials - crafted for the Indian home.", "tags": ["Sofa", "Dining Table", "Bed", "Office Chair", "Bookshelf"], "stats": [{"num": "1L+", "label": "Happy Customers"}, {"num": "500+", "label": "Products"}, {"num": "4.8", "label": "Avg Rating"}]}',1,'2026-05-12 06:52:51.492761','2026-05-12 06:47:08.488951');
INSERT INTO `cms_content_blocks` (`id`,`key`,`title`,`body_md`,`data_json`,`is_active`,`updated_at`,`created_at`) VALUES (2,'trust_badges','Trust Badges Row','','{"items": [{"icon": "truck", "title": "Free Shipping", "desc": "On all orders above Rs.299"}, {"icon": "returns", "title": "Easy Returns", "desc": "30-day hassle-free returns"}, {"icon": "shield", "title": "1-Year Warranty", "desc": "On all furniture products"}, {"icon": "star", "title": "1 Lakh+ Happy Homes", "desc": "Trusted by customers across India"}]}',1,'2026-05-12 06:52:52.445863','2026-05-12 06:48:13.405843');
INSERT INTO `cms_content_blocks` (`id`,`key`,`title`,`body_md`,`data_json`,`is_active`,`updated_at`,`created_at`) VALUES (3,'promo_best_sellers','Best Sellers Promo','','{"tag": "Limited Time", "title": "Up to 40% off on", "title_accent": "Best Sellers", "desc": "Shop our most-loved products at unbeatable prices", "cta_text": "Shop Best Sellers", "cta_link": "/best-sellers", "percent": "40%"}',1,'2026-05-12 06:48:14.928561','2026-05-12 06:48:14.928668');
INSERT INTO `cms_content_blocks` (`id`,`key`,`title`,`body_md`,`data_json`,`is_active`,`updated_at`,`created_at`) VALUES (4,'announcement_bar','Announcement Bar','','{"text": "\\ud83c\\udf89 Free shipping on orders above \\u20b92999 \\u00b7 Trusted by 1 Lakh+ happy homes", "phone": "1800-123-4567"}',1,'2026-05-23 16:40:26.908810','2026-05-12 06:48:15.960452');
INSERT INTO `cms_content_blocks` (`id`,`key`,`title`,`body_md`,`data_json`,`is_active`,`updated_at`,`created_at`) VALUES (5,'newsletter_footer','Footer Newsletter','','{"heading": "Newsletter", "desc": "Get exclusive offers, style tips, and new arrivals directly in your inbox.", "note": "No spam. Unsubscribe anytime."}',1,'2026-05-12 06:48:17.404228','2026-05-12 06:48:17.404385');
INSERT INTO `cms_content_blocks` (`id`,`key`,`title`,`body_md`,`data_json`,`is_active`,`updated_at`,`created_at`) VALUES (6,'nav_menu','Navbar Menu Override','','{"groups": [{"label": "Prestino Director Suit Series", "key": "prestino", "columns": [{"heading": "Prestino Director Suit Series", "items": [{"label": "Prestino Director Table", "slug": "desks"}, {"label": "Prestino Storage", "slug": "storage"}, {"label": "Prestino Book Shelf & Full Height", "slug": "storage"}, {"label": "Free Standing Director Table", "slug": "desks"}, {"label": "Manager Table", "slug": "desks"}, {"label": "CEO Table", "slug": "desks"}, {"label": "Chairman Suit", "slug": "sofas"}, {"label": "Modular Computer Table", "slug": "desks"}, {"label": "Conference Table Series", "slug": "tables"}, {"label": "Modular Workstation Series", "slug": "desks"}, {"label": "Modular Cabin Table", "slug": "desks"}, {"label": "Modular Workstation", "slug": "desks"}]}]}, {"label": "Modular Workstation Series", "key": "modular", "columns": [{"heading": "Modular Workstation Series", "items": [{"label": "Modular Cabin Table", "slug": "desks"}, {"label": "Modular Workstation", "slug": "desks"}]}]}, {"label": "Chair Series", "key": "chairs", "columns": [{"heading": "Chair Series", "items": [{"label": "Chairman Chair Series", "slug": "chairs"}, {"label": "Director Chair Series", "slug": "chairs"}, {"label": "Executive Chair Series", "slug": "chairs"}, {"label": "Manager Chair Series", "slug": "chairs"}, {"label": "Director Chair MSH Series", "slug": "chairs"}, {"label": "Director MSH Chair Color Series", "slug": "chairs"}, {"label": "Visitor Chair Series", "slug": "chairs"}, {"label": "Classroom Chair Series", "slug": "chairs"}, {"label": "Institutional Restaurant Chair Series", "slug": "chairs"}, {"label": "Restaurant & Bar Stool Chair Series", "slug": "chairs"}, {"label": "Restaurant & Bar Chair Series", "slug": "chairs"}, {"label": "Auditorium Chair Series", "slug": "chairs"}]}]}, {"label": "Kid Series", "key": "kids", "columns": [{"heading": "Kids Furniture", "items": [{"label": "Kid Furniture Series", "slug": "beds"}, {"label": "Kid Storage Furniture Series", "slug": "storage"}]}]}, {"label": "Hospital Furniture", "key": "hospital", "columns": [{"heading": "Hospital", "items": [{"label": "Hospital Bed Series", "slug": "beds"}, {"label": "Patient Transfer Trolley Series", "slug": "beds"}]}]}, {"label": "Other Series", "key": "others", "columns": [{"heading": "Others", "items": [{"label": "Laboratory Furniture Series", "slug": "storage"}, {"label": "Hostel Furniture Series", "slug": "beds"}, {"label": "Reception Table Series", "slug": "tables"}, {"label": "Waiting Chair Series", "slug": "chairs"}, {"label": "Office Sofa Series", "slug": "sofas"}, {"label": "Steel Furniture Series", "slug": "storage"}, {"label": "Storage Compactor Series", "slug": "storage"}, {"label": "Partition Series", "slug": "storage"}, {"label": "Chair Part & Accessories Series", "slug": "chairs"}, {"label": "Outdoor & Garden Seating", "slug": "outdoor"}, {"label": "Dining Sets", "slug": "dining-sets"}]}]}]}',1,'2026-05-12 07:28:19.152272','2026-05-12 06:48:18.419060');

DROP TABLE IF EXISTS `cms_faqs`;
CREATE TABLE `cms_faqs` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `question` varchar(300) NOT NULL,
  `answer` longtext NOT NULL,
  `category` varchar(50) NOT NULL,
  `sort_order` int(10) unsigned NOT NULL CHECK (`sort_order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `cms_faqs_category_6e8893e8` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (1,'How long does shipping take?','Standard shipping arrives in 5–7 business days. Premium 2–3 days.','Shipping',0,1,'2026-05-10 15:58:35.818777','2026-05-10 15:58:35.818803');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (2,'What is your return policy?','You can return any product within 14 days for a full refund.','Returns',0,1,'2026-05-10 15:58:40.172775','2026-05-10 15:58:40.172809');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (3,'Do you offer dealer pricing?','Yes. Apply via the Dealer Apply form; approval typically takes 1–2 days.','Dealers',0,1,'2026-05-10 15:58:44.073809','2026-05-10 15:58:44.073835');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (4,'Samir is fan of gargi ?','Yes he is if not then he is fan of soumya .','',0,1,'2026-05-12 05:59:45.180248','2026-05-12 05:59:45.180291');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (5,'Do you offer assembly services?','Yes! We offer free assembly on all furniture orders above Rs.5,000. Our trained professionals will set up your furniture at a time convenient for you.','Services',2,1,'2026-05-12 06:49:17.837271','2026-05-12 06:49:17.837298');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (6,'What payment methods do you accept?','We accept all major credit/debit cards, UPI, net banking, and cash on delivery. EMI options are available on select products.','Payments',3,1,'2026-05-12 06:49:18.325999','2026-05-12 06:49:18.326024');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (7,'Is there a warranty on your products?','All our furniture products come with a 1-year warranty covering manufacturing defects. Extended warranty options are available at checkout.','Warranty',4,1,'2026-05-12 06:49:18.817207','2026-05-12 06:49:18.817246');
INSERT INTO `cms_faqs` (`id`,`question`,`answer`,`category`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (8,'Is this a test?','Updated Answer','',0,1,'2026-05-12 08:23:43.276472','2026-05-12 08:24:42.605851');

DROP TABLE IF EXISTS `cms_newsletter`;
CREATE TABLE `cms_newsletter` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `cms_newsletter` (`id`,`email`,`is_active`,`created_at`) VALUES (1,'test-subscriber@example.com',1,'2026-05-12 09:35:00.777389');
INSERT INTO `cms_newsletter` (`id`,`email`,`is_active`,`created_at`) VALUES (2,'tester@gmail.com',1,'2026-05-12 09:40:38.208032');
INSERT INTO `cms_newsletter` (`id`,`email`,`is_active`,`created_at`) VALUES (3,'test@email.com',1,'2026-05-12 09:41:40.491168');
INSERT INTO `cms_newsletter` (`id`,`email`,`is_active`,`created_at`) VALUES (4,'test-sub@example.com',1,'2026-05-12 09:43:40.242623');
INSERT INTO `cms_newsletter` (`id`,`email`,`is_active`,`created_at`) VALUES (5,'harshchakravarti77@gmail.com',1,'2026-05-26 14:50:02.768889');

DROP TABLE IF EXISTS `cms_newsletter_campaigns`;
CREATE TABLE `cms_newsletter_campaigns` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `subject` varchar(200) NOT NULL,
  `body_md` longtext NOT NULL,
  `status` varchar(20) NOT NULL,
  `sent_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (1,'Test Subject','Test Message from Admin Dashboard','queued',NULL,'2026-05-13 07:11:49.759015','2026-05-13 07:11:49.759061');
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (2,'Congratulations! Your Application Has Been Shortlisted','Dear Harsh,

Congratulations!

We are pleased to inform you that your profile has been shortlisted for the next stage of our recruitment process based on your performance and application review.

Further details regarding the assessment/interview schedule will be shared with you shortly via email. Kindly keep checking your inbox regularly for updates.

We appreciate your interest and wish you the very best for the upcoming process.

Best Regards,
Talent Acquisition Team','queued',NULL,'2026-05-23 11:49:23.020137','2026-05-23 11:49:23.020184');
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (3,'Congratulations! Your Application Has Been Shortlisted','Dear Harsh,

Congratulations!

We are pleased to inform you that your profile has been shortlisted for the next stage of our recruitment process based on your performance and application review.

Further details regarding the assessment/interview schedule will be shared with you shortly via email. Kindly keep checking your inbox regularly for updates.

We appreciate your interest and wish you the very best for the upcoming process.

Best Regards,
Talent Acquisition Team','sent','2026-05-23 13:10:31.234256','2026-05-23 13:10:30.361463','2026-05-23 13:10:30.361498');
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (4,'wsaswdasd','sdfsdfsdfsdf','sent','2026-05-25 16:43:52.436624','2026-05-25 16:43:46.854385','2026-05-25 16:43:46.854418');
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (5,'dasas','wdsfdv','sent','2026-05-25 16:44:44.905656','2026-05-25 16:44:44.154417','2026-05-25 16:44:44.154445');
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (6,'helloo','hiii gargi....','sent','2026-05-26 15:06:00.525954','2026-05-26 15:05:59.767246','2026-05-26 15:05:59.767284');
INSERT INTO `cms_newsletter_campaigns` (`id`,`subject`,`body_md`,`status`,`sent_at`,`created_at`,`updated_at`) VALUES (7,'SNDVBHIXD','afsguyusg','sent','2026-05-29 06:54:20.749772','2026-05-29 06:54:20.023912','2026-05-29 06:54:20.023939');

DROP TABLE IF EXISTS `cms_pages`;
CREATE TABLE `cms_pages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `slug` varchar(80) NOT NULL,
  `title` varchar(200) NOT NULL,
  `body_md` longtext NOT NULL,
  `is_published` tinyint(1) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (1,'privacy','Privacy Policy','# Privacy Policy

We respect your privacy. (Edit this page in admin.)',1,'2026-05-10 15:58:31.900266','2026-05-10 15:58:31.900291');
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (2,'terms','Terms & Conditions','# Terms & Conditions

Default terms. Please customize.',1,'2026-05-10 15:58:32.801034','2026-05-10 15:58:32.801071');
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (3,'shipping-policy','Shipping Policy','## Overview
We offer reliable shipping across India with multiple delivery options.

## Delivery Timelines
- **Standard Shipping:** 5-7 business days
- **Express Shipping:** 2-3 business days (select products)
- **Same-Day Delivery:** Available in select cities

## Charges
- Free shipping on orders above Rs.299
- Flat Rs.49 shipping fee for orders under Rs.299
',1,'2026-05-12 06:49:19.332603','2026-05-12 06:49:19.332631');
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (4,'return-policy','Return Policy','## Overview
We want you to be completely satisfied with your purchase.

## Return Window
- 30-day return window from the date of delivery
- Items must be in original condition with tags attached

## Refunds
- Refunds are processed within 5-7 business days
- Original payment method will be refunded
',1,'2026-05-12 06:49:19.826971','2026-05-12 06:49:19.826997');
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (5,'privacy-policy','Privacy Policy','## Overview
Your privacy is important to us. This policy explains how we handle your data.

## Data Collected
- Name, email, phone number for order processing
- Payment information (processed securely via Razorpay)
- Browsing data for improving your experience

## Usage
- We never sell your personal data to third parties
- Data is used only for order fulfillment and communication
',1,'2026-05-12 06:49:20.326185','2026-05-12 06:49:20.326211');
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (6,'contact-us','Contact Us','## Get in Touch
We'd love to hear from you!

## Support
- **Email:** support@furnishop.in
- **Phone:** 1800-123-4567 (Mon-Sat, 9 AM - 6 PM)
- **WhatsApp:** +91 98765 43210

## Address
FurniShop HQ, Sector 62, Noida, UP - 201301
',1,'2026-05-12 06:49:20.842457','2026-05-12 06:49:20.842482');
INSERT INTO `cms_pages` (`id`,`slug`,`title`,`body_md`,`is_published`,`updated_at`,`created_at`) VALUES (7,'support','Support','## How Can We Help?
Our support team is here to assist you.

## Support Channels
- **Live Chat:** Available on the website (Mon-Sat, 9 AM - 6 PM)
- **Email Ticket:** Raise a ticket from your account dashboard
- **Phone:** 1800-123-4567

## Response Time
- Chat: Instant
- Email: Within 24 hours
- Phone: Immediate during business hours
',1,'2026-05-12 06:49:21.363638','2026-05-12 06:49:21.363663');

DROP TABLE IF EXISTS `coupon_redemptions`;
CREATE TABLE `coupon_redemptions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `discount_amount` decimal(10,2) NOT NULL,
  `redeemed_at` datetime(6) NOT NULL,
  `coupon_id` bigint(20) NOT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `coupon_redemptions_coupon_id_325f8850_fk_coupons_id` (`coupon_id`),
  KEY `coupon_redemptions_order_id_41d79b03_fk_orders_id` (`order_id`),
  KEY `coupon_redemptions_user_id_370a23b1_fk_users_id` (`user_id`),
  CONSTRAINT `coupon_redemptions_coupon_id_325f8850_fk_coupons_id` FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`),
  CONSTRAINT `coupon_redemptions_order_id_41d79b03_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `coupon_redemptions_user_id_370a23b1_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `coupon_redemptions` (`id`,`discount_amount`,`redeemed_at`,`coupon_id`,`order_id`,`user_id`) VALUES (1,'26499.50','2026-05-18 08:15:26.718392',3,25,14);
INSERT INTO `coupon_redemptions` (`id`,`discount_amount`,`redeemed_at`,`coupon_id`,`order_id`,`user_id`) VALUES (2,'27061.50','2026-05-25 16:54:12.438410',3,44,21);

DROP TABLE IF EXISTS `coupons`;
CREATE TABLE `coupons` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(40) NOT NULL,
  `description` varchar(200) NOT NULL,
  `type` varchar(10) NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `min_subtotal` decimal(10,2) NOT NULL,
  `max_discount` decimal(10,2) NOT NULL,
  `max_uses` int(10) unsigned NOT NULL CHECK (`max_uses` >= 0),
  `used_count` int(10) unsigned NOT NULL CHECK (`used_count` >= 0),
  `per_user_limit` smallint(5) unsigned NOT NULL CHECK (`per_user_limit` >= 0),
  `allowed_role` varchar(10) NOT NULL,
  `valid_from` datetime(6) DEFAULT NULL,
  `valid_until` datetime(6) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `coupons_is_active_c4b38671` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `coupons` (`id`,`code`,`description`,`type`,`value`,`min_subtotal`,`max_discount`,`max_uses`,`used_count`,`per_user_limit`,`allowed_role`,`valid_from`,`valid_until`,`is_active`,`created_at`,`updated_at`) VALUES (1,'WELCOME10','','percent','10.00','1000.00','0.00',0,0,1,'any',NULL,NULL,1,'2026-05-11 04:38:37.422545','2026-05-11 04:38:37.422567');
INSERT INTO `coupons` (`id`,`code`,`description`,`type`,`value`,`min_subtotal`,`max_discount`,`max_uses`,`used_count`,`per_user_limit`,`allowed_role`,`valid_from`,`valid_until`,`is_active`,`created_at`,`updated_at`) VALUES (2,'FURN2WDYLPTESTCOUPON50','','percent','10.00','1000.00','0.00',0,0,1,'any',NULL,NULL,1,'2026-05-11 08:40:16.120874','2026-05-11 08:40:16.120927');
INSERT INTO `coupons` (`id`,`code`,`description`,`type`,`value`,`min_subtotal`,`max_discount`,`max_uses`,`used_count`,`per_user_limit`,`allowed_role`,`valid_from`,`valid_until`,`is_active`,`created_at`,`updated_at`) VALUES (3,'TEST50','','percent','50.00','1000.00','0.00',0,2,1,'any',NULL,NULL,1,'2026-05-11 08:40:55.417381','2026-05-11 08:40:55.417478');

DROP TABLE IF EXISTS `dealer_credit`;
CREATE TABLE `dealer_credit` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `credit_limit` decimal(12,2) NOT NULL,
  `amount_used` decimal(12,2) NOT NULL,
  `terms_days` int(10) unsigned NOT NULL CHECK (`terms_days` >= 0),
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `dealer_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealer_id` (`dealer_id`),
  CONSTRAINT `dealer_credit_dealer_id_e34b6613_fk_users_id` FOREIGN KEY (`dealer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `dealer_credit` (`id`,`credit_limit`,`amount_used`,`terms_days`,`is_active`,`created_at`,`updated_at`,`dealer_id`) VALUES (1,'100000.00','39081.60',45,1,'2026-05-10 16:17:12.996898','2026-05-13 13:31:46.502179',8);
INSERT INTO `dealer_credit` (`id`,`credit_limit`,`amount_used`,`terms_days`,`is_active`,`created_at`,`updated_at`,`dealer_id`) VALUES (2,'0.00','0.00',30,1,'2026-05-18 08:24:34.840892','2026-05-18 08:24:34.840938',15);

DROP TABLE IF EXISTS `dealer_payments`;
CREATE TABLE `dealer_payments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `amount` decimal(12,2) NOT NULL,
  `method` varchar(20) NOT NULL,
  `reference` varchar(80) NOT NULL,
  `note` longtext NOT NULL,
  `received_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `dealer_id` bigint(20) NOT NULL,
  `invoice_id` bigint(20) DEFAULT NULL,
  `recorded_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dealer_payments_invoice_id_420e3ba2_fk_invoices_id` (`invoice_id`),
  KEY `dealer_payments_recorded_by_id_7b453335_fk_users_id` (`recorded_by_id`),
  KEY `dealer_paym_dealer__990590_idx` (`dealer_id`,`received_at`),
  CONSTRAINT `dealer_payments_dealer_id_0d139e56_fk_users_id` FOREIGN KEY (`dealer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `dealer_payments_invoice_id_420e3ba2_fk_invoices_id` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `dealer_payments_recorded_by_id_7b453335_fk_users_id` FOREIGN KEY (`recorded_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `dealer_payments` (`id`,`amount`,`method`,`reference`,`note`,`received_at`,`created_at`,`dealer_id`,`invoice_id`,`recorded_by_id`) VALUES (1,'306027.39','razorpay','ORD-098807E9','Backfilled from order ORD-098807E9','2026-05-11 04:42:02.408347','2026-05-11 05:09:00.820640',8,4,NULL);
INSERT INTO `dealer_payments` (`id`,`amount`,`method`,`reference`,`note`,`received_at`,`created_at`,`dealer_id`,`invoice_id`,`recorded_by_id`) VALUES (3,'214760.00','razorpay','ORD-E9C749FD','Auto-recorded from order ORD-E9C749FD (razorpay)','2026-05-11 12:21:44.654828','2026-05-11 12:21:44.655444',8,8,NULL);
INSERT INTO `dealer_payments` (`id`,`amount`,`method`,`reference`,`note`,`received_at`,`created_at`,`dealer_id`,`invoice_id`,`recorded_by_id`) VALUES (4,'807120.00','razorpay','ORD-2BF5E771','Auto-recorded from order ORD-2BF5E771 (razorpay)','2026-05-11 14:41:13.209441','2026-05-11 14:41:13.210222',8,9,NULL);
INSERT INTO `dealer_payments` (`id`,`amount`,`method`,`reference`,`note`,`received_at`,`created_at`,`dealer_id`,`invoice_id`,`recorded_by_id`) VALUES (6,'37127.52','razorpay','ORD-FEA58B40','Auto-recorded from order ORD-FEA58B40 (razorpay)','2026-05-13 13:29:48.453388','2026-05-13 13:29:48.453968',8,13,NULL);
INSERT INTO `dealer_payments` (`id`,`amount`,`method`,`reference`,`note`,`received_at`,`created_at`,`dealer_id`,`invoice_id`,`recorded_by_id`) VALUES (7,'37127.52','razorpay','ORD-BCD0811D','Auto-recorded from order ORD-BCD0811D (razorpay)','2026-05-13 13:31:29.430931','2026-05-13 13:31:29.431530',8,15,NULL);
INSERT INTO `dealer_payments` (`id`,`amount`,`method`,`reference`,`note`,`received_at`,`created_at`,`dealer_id`,`invoice_id`,`recorded_by_id`) VALUES (8,'18563.76','razorpay','ORD-DCE0DE20','Auto-recorded from order ORD-DCE0DE20 (razorpay)','2026-05-14 10:49:18.496707','2026-05-14 10:49:18.497305',8,19,NULL);

DROP TABLE IF EXISTS `dealer_tiers`;
CREATE TABLE `dealer_tiers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `slug` varchar(20) NOT NULL,
  `name` varchar(80) NOT NULL,
  `default_discount_pct` decimal(5,2) NOT NULL,
  `sort_order` int(10) unsigned NOT NULL CHECK (`sort_order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `dealer_tiers` (`id`,`slug`,`name`,`default_discount_pct`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (1,'standard','Standard Dealer','25.00',0,1,'2026-05-10 15:45:27.187792','2026-05-10 15:45:27.187820');
INSERT INTO `dealer_tiers` (`id`,`slug`,`name`,`default_discount_pct`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (2,'premium','Premium Dealer','31.00',1,1,'2026-05-10 15:45:27.714423','2026-05-10 15:45:27.714460');
INSERT INTO `dealer_tiers` (`id`,`slug`,`name`,`default_discount_pct`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (3,'platinum','Platinum Dealer','36.00',2,1,'2026-05-10 15:45:28.557082','2026-05-10 15:45:28.557165');
INSERT INTO `dealer_tiers` (`id`,`slug`,`name`,`default_discount_pct`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (4,'vip','VIP','40.00',3,1,'2026-05-13 11:11:05.289257','2026-05-13 11:11:05.289309');

DROP TABLE IF EXISTS `dealer_wallets`;
CREATE TABLE `dealer_wallets` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `balance` decimal(12,2) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `dealer_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealer_id` (`dealer_id`),
  CONSTRAINT `dealer_wallets_dealer_id_8aca2cf8_fk_users_id` FOREIGN KEY (`dealer_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `dealer_wallets` (`id`,`balance`,`is_active`,`created_at`,`updated_at`,`dealer_id`) VALUES (1,'10000.00',1,'2026-05-10 16:17:22.536800','2026-05-10 16:17:22.536837',8);
INSERT INTO `dealer_wallets` (`id`,`balance`,`is_active`,`created_at`,`updated_at`,`dealer_id`) VALUES (2,'0.00',1,'2026-05-18 08:28:06.725567','2026-05-18 08:28:06.725639',15);

DROP TABLE IF EXISTS `discounts`;
CREATE TABLE `discounts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `discount_type` varchar(10) NOT NULL,
  `mode` varchar(10) NOT NULL,
  `value` decimal(10,2) NOT NULL,
  `count_limit` int(10) unsigned DEFAULT NULL CHECK (`count_limit` >= 0),
  `units_sold` int(10) unsigned NOT NULL CHECK (`units_sold` >= 0),
  `active` tinyint(1) NOT NULL,
  `starts_at` datetime(6) DEFAULT NULL,
  `ends_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) NOT NULL,
  `min_quantity` int(10) unsigned NOT NULL CHECK (`min_quantity` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `discounts_product_id_discount_type_min_quantity_902d9f18_uniq` (`product_id`,`discount_type`,`min_quantity`),
  KEY `discounts_created_by_id_15fe0150_fk_users_id` (`created_by_id`),
  KEY `discounts_product_abc4d6_idx` (`product_id`,`discount_type`),
  KEY `discounts_active_b7955c_idx` (`active`),
  CONSTRAINT `discounts_created_by_id_15fe0150_fk_users_id` FOREIGN KEY (`created_by_id`) REFERENCES `users` (`id`),
  CONSTRAINT `discounts_product_id_e8ecce4f_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `discounts` (`id`,`discount_type`,`mode`,`value`,`count_limit`,`units_sold`,`active`,`starts_at`,`ends_at`,`created_at`,`updated_at`,`created_by_id`,`product_id`,`min_quantity`) VALUES (3,'user','percent','10.00',1,0,1,'2026-05-18 06:27:00','2026-05-18 07:27:00','2026-05-18 06:27:22.231031','2026-05-18 06:27:22.231047',6,16,1);
INSERT INTO `discounts` (`id`,`discount_type`,`mode`,`value`,`count_limit`,`units_sold`,`active`,`starts_at`,`ends_at`,`created_at`,`updated_at`,`created_by_id`,`product_id`,`min_quantity`) VALUES (4,'user','percent','70.00',NULL,0,1,'2026-05-29 06:06:00','2026-05-29 07:06:00','2026-05-29 06:06:39.449301','2026-05-29 06:06:39.449312',6,23,1);

DROP TABLE IF EXISTS `django_admin_log`;
CREATE TABLE `django_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext DEFAULT NULL,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint(5) unsigned NOT NULL CHECK (`action_flag` >= 0),
  `change_message` longtext NOT NULL,
  `content_type_id` int(11) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_users_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `django_content_type`;
CREATE TABLE `django_content_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (1,'admin','logentry');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (70,'api','award');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (71,'api','calculator');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (102,'api','catalogitem');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (106,'api','chatbotquickreply');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (107,'api','chatbotsettings');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (89,'api','city');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (72,'api','contactmessage');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (73,'api','deliveredhome');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (74,'api','design');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (90,'api','designcategory');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (93,'api','designimage');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (105,'api','designprocessstep');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (94,'api','designspec');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (95,'api','designsubcategory');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (96,'api','estimateconfig');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (75,'api','faq');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (101,'api','footerlink');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (76,'api','heroslide');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (87,'api','inspirationimage');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (77,'api','inspirationtab');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (78,'api','lead');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (79,'api','magazinearticle');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (100,'api','navitem');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (80,'api','offering');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (103,'api','packagegalleryimage');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (104,'api','packageroom');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (81,'api','processstep');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (82,'api','project');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (88,'api','projectimage');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (83,'api','review');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (99,'api','saveddesign');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (97,'api','savedestimate');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (91,'api','sitesettings');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (84,'api','store');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (92,'api','teammember');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (85,'api','trendingproduct');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (98,'api','userprofile');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (86,'api','whychooseusstat');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (30,'audit','auditlog');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (3,'auth','group');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (2,'auth','permission');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (34,'cms','banner');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (58,'cms','contentblock');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (35,'cms','faq');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (59,'cms','newslettercampaign');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (56,'cms','newslettersubscriber');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (36,'cms','page');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (4,'contenttypes','contenttype');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (49,'coupons','coupon');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (50,'coupons','couponredemption');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (47,'dealer_credit','dealercredit');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (48,'dealer_credit','dealerpayment');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (45,'dealer_pricing','dealertier');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (46,'dealer_pricing','negotiatedprice');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (52,'dealer_wallet','dealerwallet');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (53,'dealer_wallet','wallettransaction');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (28,'discounts','discount');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (32,'inventory','stocklevel');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (33,'inventory','stockmovement');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (31,'inventory','warehouse');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (40,'invoices','invoice');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (39,'invoices','invoicecounter');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (41,'invoices','invoiceitem');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (38,'media_lib','mediaasset');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (61,'notifications','newsletter');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (37,'notifications','notification');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (57,'notifications','notificationpreference');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (62,'notifications','subscriber');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (23,'orders','order');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (24,'orders','orderitem');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (25,'orders','orderreturn');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (26,'orders','refund');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (27,'payments','payment');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (16,'products','category');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (21,'products','deliveryrule');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (17,'products','product');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (18,'products','productmedia');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (19,'products','productspecification');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (20,'products','productvariant');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (63,'products','stockalert');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (22,'products','tag');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (42,'reviews','review');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (43,'reviews','reviewvote');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (5,'sessions','session');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (51,'shipping','shippingzone');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (68,'sites','site');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (66,'sms_campaigns','campaign');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (64,'sms_campaigns','contact');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (65,'sms_campaigns','delivery');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (8,'social_django','association');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (9,'social_django','code');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (10,'social_django','nonce');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (12,'social_django','partial');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (11,'social_django','usersocialauth');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (29,'store_settings','storesettings');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (67,'support','faqentry');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (54,'support','supportticket');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (55,'support','ticketmessage');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (6,'token_blacklist','blacklistedtoken');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (7,'token_blacklist','outstandingtoken');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (15,'users','emailotp');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (14,'users','passwordresettoken');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (13,'users','user');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (60,'users','useraddress');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (69,'users_compat','user');
INSERT INTO `django_content_type` (`id`,`app_label`,`model`) VALUES (44,'wishlist','wishlistitem');

DROP TABLE IF EXISTS `django_migrations`;
CREATE TABLE `django_migrations` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=137 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (1,'contenttypes','0001_initial','2026-05-10 15:44:46.766100');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (2,'contenttypes','0002_remove_content_type_name','2026-05-10 15:44:47.307026');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (3,'auth','0001_initial','2026-05-10 15:44:48.455389');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (4,'auth','0002_alter_permission_name_max_length','2026-05-10 15:44:48.867623');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (5,'auth','0003_alter_user_email_max_length','2026-05-10 15:44:49.082698');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (6,'auth','0004_alter_user_username_opts','2026-05-10 15:44:49.219194');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (7,'auth','0005_alter_user_last_login_null','2026-05-10 15:44:49.305550');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (8,'auth','0006_require_contenttypes_0002','2026-05-10 15:44:49.500948');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (9,'auth','0007_alter_validators_add_error_messages','2026-05-10 15:44:49.720386');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (10,'auth','0008_alter_user_username_max_length','2026-05-10 15:44:49.968136');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (11,'auth','0009_alter_user_last_name_max_length','2026-05-10 15:44:50.329288');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (12,'auth','0010_alter_group_name_max_length','2026-05-10 15:44:50.776878');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (13,'auth','0011_update_proxy_permissions','2026-05-10 15:44:51.394889');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (14,'auth','0012_alter_user_first_name_max_length','2026-05-10 15:44:51.568819');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (15,'users','0001_initial','2026-05-10 15:44:53.572998');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (16,'admin','0001_initial','2026-05-10 15:44:54.186035');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (17,'admin','0002_logentry_remove_auto_add','2026-05-10 15:44:54.288312');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (18,'admin','0003_logentry_add_action_flag_choices','2026-05-10 15:44:54.380991');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (19,'audit','0001_initial','2026-05-10 15:44:56.360779');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (20,'cms','0001_initial','2026-05-10 15:44:57.141119');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (21,'products','0001_initial','2026-05-10 15:44:58.273921');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (22,'orders','0001_initial','2026-05-10 15:44:58.947951');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (23,'orders','0002_order_erp_sync_status_order_updated_at_order_user_and_more','2026-05-10 15:45:00.535993');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (24,'orders','0003_order_gst_amount_order_gst_percent_and_more','2026-05-10 15:45:02.085554');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (25,'orders','0004_order_cancellation_reason_order_delivered_at_and_more','2026-05-10 15:45:05.987179');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (26,'orders','0005_order_dealer_note_order_payment_method_and_more','2026-05-10 15:45:06.934382');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (27,'orders','0006_order_coupon_code_order_coupon_discount','2026-05-10 15:45:07.836062');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (28,'coupons','0001_initial','2026-05-10 15:45:09.135785');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (29,'products','0002_add_is_featured_updated_at_description_indexes','2026-05-10 15:45:10.764082');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (30,'products','0003_alter_category_options_and_more','2026-05-10 15:45:11.239141');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (31,'products','0004_productmedia','2026-05-10 15:45:12.074714');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (32,'products','0005_backfill_product_media','2026-05-10 15:45:12.615711');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (33,'products','0006_productspecification_productvariant_and_more','2026-05-10 15:45:18.106886');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (34,'products','0007_product_brand_product_deleted_at_and_more','2026-05-10 15:45:21.330025');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (35,'invoices','0001_initial','2026-05-10 15:45:23.425842');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (36,'invoices','0002_invoice_amount_due_invoice_amount_paid','2026-05-10 15:45:23.950781');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (37,'dealer_credit','0001_initial','2026-05-10 15:45:25.060019');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (38,'dealer_pricing','0001_initial','2026-05-10 15:45:26.356179');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (39,'dealer_pricing','0002_seed_tiers','2026-05-10 15:45:28.998634');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (40,'dealer_wallet','0001_initial','2026-05-10 15:45:30.140970');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (41,'discounts','0001_initial','2026-05-10 15:45:31.238823');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (42,'discounts','0002_alter_discount_options_and_more','2026-05-10 15:45:33.671903');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (43,'inventory','0001_initial','2026-05-10 15:45:35.885120');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (44,'media_lib','0001_initial','2026-05-10 15:45:36.763950');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (45,'notifications','0001_initial','2026-05-10 15:45:37.879428');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (46,'orders','0007_order_payment_type_and_early_discount','2026-05-10 15:45:38.885827');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (47,'orders','0008_orderitem_backorder_fields','2026-05-10 15:45:40.107625');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (48,'payments','0001_initial','2026-05-10 15:45:40.781129');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (49,'payments','0002_payment_failure_reason_payment_razorpay_signature_and_more','2026-05-10 15:45:41.358276');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (50,'products','0008_product_dealer_only_product_min_order_quantity','2026-05-10 15:45:42.160265');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (51,'products','0009_delivery_rule','2026-05-10 15:45:42.672149');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (52,'products','0010_product_rich_pdp_fields','2026-05-10 15:45:44.481010');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (53,'products','0011_product_tags','2026-05-10 15:45:45.873148');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (54,'reviews','0001_initial','2026-05-10 15:45:49.187591');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (55,'sessions','0001_initial','2026-05-10 15:45:49.578041');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (56,'shipping','0001_initial','2026-05-10 15:45:50.405844');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (57,'social_django','0001_initial','2026-05-10 15:45:51.686479');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (58,'social_django','0002_add_related_name','2026-05-10 15:45:51.820411');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (59,'social_django','0003_alter_email_max_length','2026-05-10 15:45:52.001851');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (60,'social_django','0004_auto_20160423_0400','2026-05-10 15:45:52.110153');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (61,'social_django','0005_auto_20160727_2333','2026-05-10 15:45:52.366691');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (62,'social_django','0006_partial','2026-05-10 15:45:52.762022');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (63,'social_django','0007_code_timestamp','2026-05-10 15:45:53.252547');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (64,'social_django','0008_partial_timestamp','2026-05-10 15:45:53.766085');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (65,'social_django','0009_auto_20191118_0520','2026-05-10 15:45:54.613586');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (66,'social_django','0010_uid_db_index','2026-05-10 15:45:54.870893');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (67,'social_django','0011_alter_id_fields','2026-05-10 15:45:55.553607');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (68,'social_django','0012_usersocialauth_extra_data_new','2026-05-10 15:45:56.380641');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (69,'social_django','0013_migrate_extra_data','2026-05-10 15:45:56.996135');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (70,'social_django','0014_remove_usersocialauth_extra_data','2026-05-10 15:45:57.319588');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (71,'social_django','0015_rename_extra_data_new_usersocialauth_extra_data','2026-05-10 15:45:57.633704');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (72,'social_django','0016_alter_usersocialauth_extra_data','2026-05-10 15:45:57.755873');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (73,'social_django','0017_usersocialauth_user_social_auth_uid_required','2026-05-10 15:45:58.003186');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (74,'store_settings','0001_initial','2026-05-10 15:45:58.446169');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (75,'support','0001_initial','2026-05-10 15:46:01.034856');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (76,'token_blacklist','0001_initial','2026-05-10 15:46:01.790977');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (77,'token_blacklist','0002_outstandingtoken_jti_hex','2026-05-10 15:46:02.033284');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (78,'token_blacklist','0003_auto_20171017_2007','2026-05-10 15:46:02.551402');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (79,'token_blacklist','0004_auto_20171017_2013','2026-05-10 15:46:02.888309');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (80,'token_blacklist','0005_remove_outstandingtoken_jti','2026-05-10 15:46:03.109175');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (81,'token_blacklist','0006_auto_20171017_2113','2026-05-10 15:46:03.341276');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (82,'token_blacklist','0007_auto_20171017_2214','2026-05-10 15:46:04.613619');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (83,'token_blacklist','0008_migrate_to_bigautofield','2026-05-10 15:46:05.999495');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (84,'token_blacklist','0010_fix_migrate_to_bigautofield','2026-05-10 15:46:06.176586');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (85,'token_blacklist','0011_linearizes_history','2026-05-10 15:46:06.327408');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (86,'token_blacklist','0012_alter_outstandingtoken_user','2026-05-10 15:46:06.464620');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (87,'token_blacklist','0013_alter_blacklistedtoken_options_and_more','2026-05-10 15:46:06.596444');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (88,'users','0002_alter_user_options_user_dealer_company_name_and_more','2026-05-10 15:46:07.652494');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (89,'users','0003_user_is_blocked','2026-05-10 15:46:07.987925');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (90,'users','0004_user_dealer_territory_user_dealer_tier','2026-05-10 15:46:08.466279');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (91,'users','0005_passwordresettoken','2026-05-10 15:46:08.927336');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (92,'users','0006_emailotp','2026-05-10 15:46:09.546184');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (93,'wishlist','0001_initial','2026-05-10 15:46:10.424491');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (94,'support','0002_supportticket_guest_email_supportticket_guest_name_and_more','2026-05-11 12:36:19.175463');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (95,'cms','0002_newslettersubscriber','2026-05-11 12:58:01.215199');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (96,'notifications','0002_notificationpreference','2026-05-12 05:03:08.727138');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (97,'cms','0003_content_blocks_and_newsletter_campaigns','2026-05-12 06:33:24.515168');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (98,'users','0007_useraddress','2026-05-12 08:13:31.142580');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (99,'notifications','0003_newsletter_subscriber','2026-05-12 15:09:19.949394');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (100,'orders','0009_order_billing_company_name_order_billing_gstin','2026-05-13 07:56:36.882817');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (101,'products','0012_stockalert_and_more','2026-05-13 07:57:05.724514');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (102,'sms_campaigns','0001_initial','2026-05-19 08:26:10.425029');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (103,'orders','0010_refund_gateway_payload','2026-05-19 08:35:09.245787');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (104,'users','0008_rename_users_user__is_def_2f8e19_idx_user_addres_user_id_f26943_idx_and_more','2026-05-19 08:35:09.690569');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (105,'payments','0003_payment_email_sent_at','2026-05-22 13:37:09.810560');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (106,'notifications','0004_subscriber_welcomed_at','2026-05-22 13:54:01.665106');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (107,'invoices','0003_invoice_coupon_code_invoice_coupon_discount','2026-05-22 14:00:18.062849');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (108,'payments','0004_payment_sms_sent_at','2026-05-22 18:45:07.316514');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (109,'support','0003_faqentry','2026-05-23 09:31:16.401404');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (111,'users_compat','0001_initial','2020-01-01 00:00:00');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (112,'api','0001_initial','2026-05-26 18:23:07.829488');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (113,'api','0002_design_category_slug_design_description_and_more','2026-05-26 18:23:13.217389');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (114,'api','0003_city_designcategory_sitesettings_teammember_and_more','2026-05-26 18:23:15.762005');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (115,'api','0004_design_tags_project_description_project_slug','2026-05-26 18:23:17.646282');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (116,'api','0005_estimateconfig','2026-05-26 18:23:18.261929');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (117,'api','0006_show_on_homepage','2026-05-26 18:23:19.082154');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (118,'api','0007_design_show_on_homepage','2026-05-26 18:23:19.609205');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (119,'api','0008_contactmessage_user_lead_calculator_type_lead_design_and_more','2026-05-26 18:23:22.489181');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (120,'api','0009_convert_design_category_project_city_tags','2026-05-26 18:23:29.628816');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (121,'api','0010_navitem','2026-05-26 18:23:29.935804');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (122,'api','0011_seed_navitems','2026-05-26 18:23:31.573733');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (123,'api','0012_add_filter_indexes','2026-05-26 18:23:31.921820');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (124,'api','0013_add_lead_pin_code','2026-05-26 18:23:32.329452');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (125,'api','0014_footerlink_model','2026-05-26 18:23:32.776099');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (126,'api','0015_seed_footerlinks','2026-05-26 18:24:32.949111');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (127,'api','0016_footerlink_bottom_bar_only','2026-05-26 18:24:33.065582');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (128,'api','0017_reseed_footerlinks','2026-05-26 18:24:33.977732');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (129,'api','0018_catalogitem_packagegalleryimage_packageroom','2026-05-26 18:24:36.598792');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (130,'api','0019_designprocessstep','2026-05-26 18:24:36.818074');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (131,'api','0020_chatbotquickreply_chatbotsettings','2026-05-26 18:24:37.149541');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (132,'sites','0001_initial','2026-05-26 18:24:37.406930');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (133,'sites','0002_alter_domain_unique','2026-05-26 18:24:37.614410');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (134,'api','0021_add_maintenance_mode','2026-05-27 06:51:46.244499');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (135,'api','0022_add_lead_customizations','2026-05-27 08:07:11.249716');
INSERT INTO `django_migrations` (`id`,`app`,`name`,`applied`) VALUES (136,'api','0023_add_design_filter_indexes','2026-05-27 14:10:51.288201');

DROP TABLE IF EXISTS `django_session`;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `django_session` (`session_key`,`session_data`,`expire_date`) VALUES ('32lq1osdcm3x1syz8v14dtn12eucufvr','.eJxVy0EOwiAQheG7sDaE6XRocefKpUcgMAylsZGk2JXx7lbjQlcv-V--h_Jhuxe_NVn9nNRRjerw22Lgq9zeR6s8h8VzXUV_a9NTrdMi-vyZy2ln3b8voZUdA0K2aEyiQRDQBcRucIRM0cWUacwxOMqWmLID7JkZWCKmHoxNWdTzBY4ZN5k:1wMp65:ItAQd57mt68tlBL0-0Y0txO02YySzopzN5I9Psz6jsY','2026-05-19 15:32:37.093704');
INSERT INTO `django_session` (`session_key`,`session_data`,`expire_date`) VALUES ('b3e205pp2wwgm7bxr0327gu18adyfcll','eyJjYXJ0Ijp7fX0:1wRPMa:uz8dTPydJLAOflG25NQvFUo-jL25MMPsZvJ28414RYA','2026-06-01 07:04:36.959631');
INSERT INTO `django_session` (`session_key`,`session_data`,`expire_date`) VALUES ('p151156mggcqarcw3sgqyvvipmihvhdv','eyJjYXJ0Ijp7fX0:1wRvCx:mkKF29xkArGQotdfGGrr8y_PuUTFlvWFfliydVvWZtE','2026-06-02 17:04:47.862487');
INSERT INTO `django_session` (`session_key`,`session_data`,`expire_date`) VALUES ('r9pzli9gtucknfddirzxjvchp0e4kqhj','.eJxVy0EOwiAQheG7sDaE6XRocefKpUcgMAylsZGk2JXx7lbjQlcv-V--h_Jhuxe_NVn9nNRRjerw22Lgq9zeR6s8h8VzXUV_a9NTrdMi-vyZy2ln3b8voZUdA0K2aEyiQRDQBcRucIRM0cWUacwxOMqWmLID7JkZWCKmHoxNWdTzBY4ZN5k:1wMp6b:OU_DJuiF8C8vU-bXJEq8HryRro6PQB5LQiDHzdFBRE8','2026-05-19 15:33:09.334814');
INSERT INTO `django_session` (`session_key`,`session_data`,`expire_date`) VALUES ('wywcnq1wauw6e7y78c2tbvxjisfqvifm','.eJxVy0EOwiAQheG7sDaE6XRocefKpUcgMAylsZGk2JXx7lbjQlcv-V--h_Jhuxe_NVn9nNRRjerw22Lgq9zeR6s8h8VzXUV_a9NTrdMi-vyZy2ln3b8voZUdA0K2aEyiQRDQBcRucIRM0cWUacwxOMqWmLID7JkZWCKmHoxNWdTzBY4ZN5k:1wMp72:ODZDPprlS9cPR0j0kdIBYdYF7poiM0EgUmnI7z2IIwA','2026-05-19 15:33:36.095242');

DROP TABLE IF EXISTS `django_site`;
CREATE TABLE `django_site` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `domain` varchar(100) NOT NULL,
  `name` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_site_domain_a2e37b91_uniq` (`domain`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `django_site` (`id`,`domain`,`name`) VALUES (1,'example.com','example.com');

DROP TABLE IF EXISTS `email_otps`;
CREATE TABLE `email_otps` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `code` varchar(6) NOT NULL,
  `purpose` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `used_at` datetime(6) DEFAULT NULL,
  `attempts` smallint(5) unsigned NOT NULL CHECK (`attempts` >= 0),
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `email_otps_user_id_40a9dd8c_fk_users_id` (`user_id`),
  KEY `email_otps_code_2e8adaa0` (`code`),
  CONSTRAINT `email_otps_user_id_40a9dd8c_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (2,'659238','signup','2026-05-23 04:48:40.939623','2026-05-23 05:03:40.938003','2026-05-23 13:12:06.180776',0,17);
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (4,'390867','login','2026-05-23 13:12:06.363969','2026-05-23 13:22:06.363372','2026-05-25 06:23:16.211661',0,17);
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (5,'070469','signup','2026-05-23 13:19:57.909038','2026-05-23 13:34:57.908526','2026-05-23 13:20:26.827601',0,19);
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (6,'521209','login','2026-05-25 06:23:16.409856','2026-05-25 06:33:16.409353','2026-05-25 06:23:31.764539',0,17);
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (7,'927520','signup','2026-05-25 15:56:25.842646','2026-05-25 16:11:25.842250','2026-05-25 15:57:08.186379',0,21);
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (8,'364411','login','2026-05-26 14:59:34.442997','2026-05-26 15:09:34.442575','2026-05-26 15:01:05.537378',0,17);
INSERT INTO `email_otps` (`id`,`code`,`purpose`,`created_at`,`expires_at`,`used_at`,`attempts`,`user_id`) VALUES (9,'603273','login','2026-05-26 15:01:05.743453','2026-05-26 15:11:05.742671',NULL,0,17);

DROP TABLE IF EXISTS `invoice_counters`;
CREATE TABLE `invoice_counters` (
  `year` int(10) unsigned NOT NULL CHECK (`year` >= 0),
  `last_seq` int(10) unsigned NOT NULL CHECK (`last_seq` >= 0),
  PRIMARY KEY (`year`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `invoice_counters` (`year`,`last_seq`) VALUES (2026,24);

DROP TABLE IF EXISTS `invoice_items`;
CREATE TABLE `invoice_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_name` varchar(255) NOT NULL,
  `product_sku` varchar(40) NOT NULL,
  `variant_label` varchar(120) NOT NULL,
  `hsn_code` varchar(10) NOT NULL,
  `quantity` int(10) unsigned NOT NULL CHECK (`quantity` >= 0),
  `unit_price` decimal(10,2) NOT NULL,
  `original_unit_price` decimal(10,2) NOT NULL,
  `line_subtotal` decimal(10,2) NOT NULL,
  `line_discount` decimal(10,2) NOT NULL,
  `cgst_rate` decimal(5,2) NOT NULL,
  `sgst_rate` decimal(5,2) NOT NULL,
  `igst_rate` decimal(5,2) NOT NULL,
  `cgst_amount` decimal(10,2) NOT NULL,
  `sgst_amount` decimal(10,2) NOT NULL,
  `igst_amount` decimal(10,2) NOT NULL,
  `line_total` decimal(10,2) NOT NULL,
  `invoice_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `invoice_items_invoice_id_96f0ca2d_fk_invoices_id` (`invoice_id`),
  KEY `invoice_items_product_id_53181905_fk_products_id` (`product_id`),
  KEY `invoice_items_variant_id_b234e9af_fk_product_variants_id` (`variant_id`),
  CONSTRAINT `invoice_items_invoice_id_96f0ca2d_fk_invoices_id` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`),
  CONSTRAINT `invoice_items_product_id_53181905_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `invoice_items_variant_id_b234e9af_fk_product_variants_id` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=36 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (1,'Samir','BED-E908DB','','6767',1,'19000.00','24000.00','19000.00','5000.00','0.00','0.00','18.00','0.00','0.00','3420.00','22420.00',1,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (2,'Rattan Outdoor Lounge Set','OUT-441F37','','',1,'52999.00','52999.00','52999.00','0.00','0.00','0.00','18.00','0.00','0.00','9539.82','62538.82',2,16,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (3,'Teak Garden Bench','OUT-489666','','',1,'14999.00','14999.00','14999.00','0.00','0.00','0.00','18.00','0.00','0.00','2699.82','17698.82',2,15,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (4,'Compact 4-Seater Dining Set','DIN-7651BC','','',2,'36999.00','36999.00','73998.00','0.00','0.00','0.00','18.00','0.00','0.00','13319.64','87317.64',2,14,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (5,'Samir','BED-E908DB','','6767',1,'24000.00','24000.00','24000.00','0.00','0.00','0.00','18.00','0.00','0.00','4320.00','28320.00',3,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (6,'Rattan Outdoor Lounge Set','OUT-441F37','','',2,'52999.00','52999.00','105998.00','0.00','0.00','0.00','18.00','0.00','0.00','19079.64','125077.64',4,16,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (7,'Teak Garden Bench','OUT-489666','','',1,'14999.00','14999.00','14999.00','0.00','0.00','0.00','18.00','0.00','0.00','2699.82','17698.82',4,15,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (8,'Samir','BED-E908DB','','6767',1,'24000.00','24000.00','24000.00','0.00','0.00','0.00','18.00','0.00','0.00','4320.00','28320.00',4,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (9,'6-Seater Teak Dining Set','DIN-F44E83','','',1,'84999.00','84999.00','84999.00','0.00','0.00','0.00','18.00','0.00','0.00','15299.82','100298.82',4,13,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (10,'Height Adjustable Standing Desk','DES-67F190','','',1,'42999.00','42999.00','42999.00','0.00','0.00','0.00','18.00','0.00','0.00','7739.82','50738.82',4,12,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (11,'Samir','BED-E908DB','','6767',6,'24000.00','24000.00','144000.00','0.00','0.00','0.00','18.00','0.00','0.00','25920.00','169920.00',5,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (12,'Samir','BED-E908DB','','6767',14,'24000.00','24000.00','336000.00','0.00','0.00','0.00','18.00','0.00','0.00','60480.00','396480.00',6,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (13,'Teak Garden Bench','OUT-489666','','',3,'14999.00','14999.00','44997.00','0.00','0.00','0.00','18.00','0.00','0.00','8099.46','53096.46',7,15,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (14,'Compact 4-Seater Dining Set','DIN-7651BC','','',2,'36999.00','36999.00','73998.00','0.00','0.00','0.00','18.00','0.00','0.00','13319.64','87317.64',7,14,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (15,'Test Product XYZ','BED-A5377A','','',7,'26000.00','26000.00','182000.00','0.00','0.00','0.00','18.00','0.00','0.00','32760.00','214760.00',8,18,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (16,'Samir','BED-E908DB','','6767',30,'24000.00','24000.00','720000.00','0.00','0.00','0.00','18.00','0.00','0.00','129600.00','849600.00',9,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (20,'Samir','BED-E908DB','','6767',2,'16560.00','24000.00','33120.00','14880.00','0.00','0.00','18.00','0.00','0.00','5961.60','39081.60',13,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (21,'Samir','BED-E908DB','','6767',1,'16560.00','24000.00','16560.00','7440.00','0.00','0.00','18.00','0.00','0.00','2980.80','19540.80',14,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (22,'Samir','BED-E908DB','','6767',2,'16560.00','24000.00','33120.00','14880.00','0.00','0.00','18.00','0.00','0.00','5961.60','39081.60',15,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (23,'Samir','BED-E908DB','','6767',1,'16560.00','24000.00','16560.00','7440.00','0.00','0.00','18.00','0.00','0.00','2980.80','19540.80',16,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (24,'Samir','BED-E908DB','','6767',1,'24000.00','24000.00','24000.00','0.00','0.00','0.00','18.00','0.00','0.00','4320.00','28320.00',17,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (25,'Samir','BED-E908DB','','6767',1,'24000.00','24000.00','24000.00','0.00','0.00','0.00','18.00','0.00','0.00','4320.00','28320.00',18,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (26,'Samir','BED-E908DB','','6767',1,'16560.00','24000.00','16560.00','7440.00','0.00','0.00','18.00','0.00','0.00','2980.80','19540.80',19,17,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (27,'Rattan Outdoor Lounge Set','OUT-441F37','','',1,'52999.00','52999.00','52999.00','0.00','0.00','0.00','18.00','0.00','0.00','9539.82','62538.82',20,16,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (31,'Teak Garden Bench','OUT-489666','','',1,'14999.00','14999.00','14999.00','0.00','0.00','0.00','18.00','0.00','0.00','2699.82','17698.82',24,15,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (32,'Compact 4-Seater Dining Set','DIN-7651BC','','',1,'36999.00','36999.00','36999.00','0.00','0.00','0.00','18.00','0.00','0.00','6659.82','43658.82',24,14,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (33,'Teak Garden Bench','OUT-489666','','',1,'14999.00','14999.00','14999.00','0.00','0.00','0.00','18.00','0.00','0.00','2699.82','17698.82',25,15,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (34,'Teak Garden Bench','OUT-489666','','',1,'14999.00','14999.00','14999.00','0.00','0.00','0.00','18.00','0.00','0.00','2699.82','17698.82',26,15,NULL);
INSERT INTO `invoice_items` (`id`,`product_name`,`product_sku`,`variant_label`,`hsn_code`,`quantity`,`unit_price`,`original_unit_price`,`line_subtotal`,`line_discount`,`cgst_rate`,`sgst_rate`,`igst_rate`,`cgst_amount`,`sgst_amount`,`igst_amount`,`line_total`,`invoice_id`,`product_id`,`variant_id`) VALUES (35,'Varun','BED-7F32B1','','9403',1,'54123.00','54123.00','54123.00','0.00','0.00','0.00','18.00','0.00','0.00','9742.14','63865.14',27,26,NULL);

DROP TABLE IF EXISTS `invoices`;
CREATE TABLE `invoices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `invoice_number` varchar(20) NOT NULL,
  `billing_name` varchar(120) NOT NULL,
  `billing_address_text` longtext NOT NULL,
  `billing_pincode` varchar(10) NOT NULL,
  `billing_state` varchar(80) NOT NULL,
  `shipping_address_text` longtext NOT NULL,
  `store_name` varchar(120) NOT NULL,
  `store_legal_name` varchar(200) NOT NULL,
  `store_gstin` varchar(15) NOT NULL,
  `store_address` longtext NOT NULL,
  `store_email` varchar(254) NOT NULL,
  `store_phone` varchar(20) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  `discount_total` decimal(10,2) NOT NULL,
  `cgst_total` decimal(10,2) NOT NULL,
  `sgst_total` decimal(10,2) NOT NULL,
  `igst_total` decimal(10,2) NOT NULL,
  `shipping_total` decimal(10,2) NOT NULL,
  `grand_total` decimal(10,2) NOT NULL,
  `payment_status` varchar(10) NOT NULL,
  `payment_method` varchar(20) NOT NULL,
  `invoice_date` date NOT NULL,
  `due_date` date DEFAULT NULL,
  `pdf_url` varchar(500) NOT NULL,
  `emailed_at` datetime(6) DEFAULT NULL,
  `notes` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `customer_id` bigint(20) DEFAULT NULL,
  `order_id` bigint(20) NOT NULL,
  `amount_due` decimal(12,2) NOT NULL,
  `amount_paid` decimal(12,2) NOT NULL,
  `coupon_code` varchar(40) NOT NULL,
  `coupon_discount` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_number` (`invoice_number`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `invoices_payment_1e70a6_idx` (`payment_status`,`created_at`),
  KEY `invoices_custome_38a61a_idx` (`customer_id`,`created_at`),
  KEY `invoices_payment_status_1e853a30` (`payment_status`),
  CONSTRAINT `invoices_customer_id_de4a11fb_fk_users_id` FOREIGN KEY (`customer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `invoices_order_id_ebb2d34a_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (1,'INV-2026-00001','Dev User','asdfghjkl asdfghjkl; asdfghjkl asdfghjkl','','','','FurniShop','','','','','','19000.00','5000.00','0.00','0.00','3420.00','0.00','22420.00','SUCCESS','razorpay','2026-05-10',NULL,'',NULL,'','2026-05-10 17:12:15.262787','2026-05-10 17:12:15.262809',7,1,'0.00','22420.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (2,'INV-2026-00002','deeke','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','','','','FurniShop','','','','','','141996.00','0.00','0.00','0.00','25559.28','0.00','167555.28','SUCCESS','razorpay','2026-05-11',NULL,'',NULL,'','2026-05-11 04:25:06.055084','2026-05-11 04:25:06.055112',NULL,6,'0.00','167555.28','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (3,'INV-2026-00003','Guest Tester','42 Test Lane, Mumbai, MH 400001','400001','Maharashtra','','FurniShop','','','','','','24000.00','0.00','0.00','0.00','4320.00','0.00','28320.00','SUCCESS','razorpay','2026-05-11',NULL,'',NULL,'','2026-05-11 04:38:32.315498','2026-05-11 04:38:32.315515',NULL,7,'0.00','28320.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (4,'INV-2026-00004','Dev Dealer','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','','','','FurniShop','','','','','','272995.00','0.00','0.00','0.00','49139.10','0.00','322134.10','SUCCESS','razorpay','2026-05-11',NULL,'',NULL,'','2026-05-11 04:40:47.798178','2026-05-11 04:40:47.798203',8,9,'0.00','322134.10','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (5,'INV-2026-00005','Dev User','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','','','','FurniShop','','','','','','144000.00','0.00','0.00','0.00','25920.00','0.00','169920.00','SUCCESS','razorpay','2026-05-11',NULL,'',NULL,'','2026-05-11 05:32:28.710048','2026-05-11 05:32:28.710244',7,10,'0.00','169920.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (6,'INV-2026-00006','Dev User','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','','','','FurniShop','','','','','','336000.00','0.00','0.00','0.00','60480.00','0.00','396480.00','SUCCESS','razorpay','2026-05-11',NULL,'',NULL,'','2026-05-11 05:34:30.104322','2026-05-11 05:34:30.104582',7,11,'0.00','396480.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (7,'INV-2026-00007','Test User Functional','123 Test Street, Apt 4B, Mumbai, Maharashtra','','','','FurniShop','','','','','','118995.00','0.00','0.00','0.00','21419.10','0.00','140414.10','SUCCESS','cod','2026-05-11',NULL,'',NULL,'','2026-05-11 08:28:20.685041','2026-05-11 08:28:20.685111',NULL,12,'0.00','140414.10','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (8,'INV-2026-00008','Dev Dealer','sdfghjhgf sdfghjhgfd sdfghjhgfd sdfghjhgfd','','','','FurniShop','','','','','','182000.00','0.00','0.00','0.00','32760.00','0.00','214760.00','SUCCESS','cod','2026-05-11',NULL,'',NULL,'','2026-05-11 12:21:43.090108','2026-05-11 12:21:43.090130',8,13,'0.00','214760.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (9,'INV-2026-00009','Dev Dealer','sdfghjk asdfghjkl asdfghjkl asdfghjk','','','','FurniShop','','','','','','720000.00','0.00','0.00','0.00','129600.00','0.00','849600.00','SUCCESS','razorpay','2026-05-11',NULL,'',NULL,'','2026-05-11 14:41:11.125479','2026-05-11 14:41:11.125502',8,14,'0.00','849600.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (13,'INV-2026-00010','Dev Dealer','Test Address Nagpur 440001','440001','Maharashtra','','FurniShop','','','','','','33120.00','14880.00','0.00','0.00','5961.60','0.00','39081.60','SUCCESS','razorpay','2026-05-13',NULL,'',NULL,'','2026-05-13 13:29:45.133594','2026-05-13 13:29:45.133615',8,18,'0.00','39081.60','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (14,'INV-2026-00011','Dev Dealer','Test Address Nagpur 440001','440001','Maharashtra','','FurniShop','','','','','','16560.00','7440.00','0.00','0.00','2980.80','0.00','19540.80','PENDING','credit','2026-05-13',NULL,'',NULL,'','2026-05-13 13:30:03.589064','2026-05-13 13:30:03.589099',8,19,'19540.80','0.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (15,'INV-2026-00012','Dev Dealer','Test Address Nagpur 440001','440001','Maharashtra','','FurniShop','','','','','','33120.00','14880.00','0.00','0.00','5961.60','0.00','39081.60','SUCCESS','razorpay','2026-05-13',NULL,'',NULL,'','2026-05-13 13:31:26.050686','2026-05-13 13:31:26.050707',8,20,'0.00','39081.60','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (16,'INV-2026-00013','Dev Dealer','Test Address Nagpur 440001','440001','Maharashtra','','FurniShop','','','','','','16560.00','7440.00','0.00','0.00','2980.80','0.00','19540.80','PENDING','credit','2026-05-13',NULL,'',NULL,'','2026-05-13 13:31:45.561386','2026-05-13 13:31:45.561415',8,21,'19540.80','0.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (17,'INV-2026-00014','Dev User','Test 12 MG Road Mumbai 400001','400001','Maharashtra','','FurniShop','','','','','','24000.00','0.00','0.00','0.00','4320.00','0.00','28320.00','SUCCESS','razorpay','2026-05-13',NULL,'',NULL,'','2026-05-13 13:33:03.365654','2026-05-13 13:33:03.365680',7,22,'0.00','28320.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (18,'INV-2026-00015','Dev User','Khapri(uma)xvxvdfvdfvbzvdj,mdf vd.vkbdvbdf','','','','FurniShop','','','','','','24000.00','0.00','0.00','0.00','4320.00','0.00','28320.00','SUCCESS','razorpay','2026-05-14',NULL,'',NULL,'','2026-05-14 10:37:00.363631','2026-05-14 10:37:00.363657',7,23,'0.00','28320.00','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (19,'INV-2026-00016','Dev Dealer','Khapri(uma)sdfsdfnsdfkjsdfsdkfsdf','','','','FurniShop','','','','','','16560.00','7440.00','0.00','0.00','2980.80','0.00','19540.80','SUCCESS','razorpay','2026-05-14',NULL,'',NULL,'','2026-05-14 10:49:15.018704','2026-05-14 10:49:15.018732',8,24,'0.00','19540.80','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (20,'INV-2026-00017','Rahul Chawla','asdfghjkl asdfghjk asdfghjkl','','','','FurniShop','','','','','','52999.00','0.00','0.00','0.00','9539.82','0.00','62538.82','SUCCESS','razorpay','2026-05-18',NULL,'',NULL,'','2026-05-18 08:15:31.876283','2026-05-18 08:15:31.876305',14,25,'0.00','62538.82','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (24,'INV-2026-00021','Dev User','dsjkkkkkkkks, ASDFGGHJ, ghjksdjfhds vghjasdhfgdhjsk, dhfvdhjsshdhfj, Mumbai, Maharashtra, 560001','560001','Karnataka','','FurniShop','','','','','','51998.00','0.00','0.00','0.00','9359.64','0.00','61357.64','SUCCESS','razorpay','2026-05-23',NULL,'',NULL,'','2026-05-23 04:32:55.989923','2026-05-23 04:32:55.989960',7,33,'0.00','61357.64','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (25,'INV-2026-00022','Dev User','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','441501','Maharashtra','','FurnoTech','','','','','','14999.00','0.00','0.00','0.00','2699.82','0.00','17698.82','SUCCESS','cod','2026-05-25',NULL,'',NULL,'','2026-05-25 06:39:41.784352','2026-05-25 06:39:41.784379',7,40,'0.00','17698.82','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (26,'INV-2026-00023','Samir Ganesh Watgule','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','441501','Maharashtra','','FurnoTech','','','','','','14999.00','0.00','0.00','0.00','2699.82','0.00','17698.82','SUCCESS','cod','2026-05-25',NULL,'',NULL,'','2026-05-25 15:58:13.752618','2026-05-25 15:58:13.752638',21,43,'0.00','17698.82','','0.00');
INSERT INTO `invoices` (`id`,`invoice_number`,`billing_name`,`billing_address_text`,`billing_pincode`,`billing_state`,`shipping_address_text`,`store_name`,`store_legal_name`,`store_gstin`,`store_address`,`store_email`,`store_phone`,`subtotal`,`discount_total`,`cgst_total`,`sgst_total`,`igst_total`,`shipping_total`,`grand_total`,`payment_status`,`payment_method`,`invoice_date`,`due_date`,`pdf_url`,`emailed_at`,`notes`,`created_at`,`updated_at`,`customer_id`,`order_id`,`amount_due`,`amount_paid`,`coupon_code`,`coupon_discount`) VALUES (27,'INV-2026-00024','Samir Ganesh Watgule','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','441501','Maharashtra','','FurnoTech','','','','','','54123.00','27061.50','0.00','0.00','9742.14','0.00','36803.64','SUCCESS','razorpay','2026-05-25',NULL,'',NULL,'','2026-05-25 16:56:39.631963','2026-05-25 16:56:39.631981',21,44,'0.00','36803.64','TEST50','27061.50');

DROP TABLE IF EXISTS `media_assets`;
CREATE TABLE `media_assets` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `public_id` varchar(200) NOT NULL,
  `secure_url` varchar(500) NOT NULL,
  `kind` varchar(8) NOT NULL,
  `bytes` int(10) unsigned NOT NULL CHECK (`bytes` >= 0),
  `width` int(10) unsigned DEFAULT NULL CHECK (`width` >= 0),
  `height` int(10) unsigned DEFAULT NULL CHECK (`height` >= 0),
  `folder` varchar(120) NOT NULL,
  `tags` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`tags`)),
  `created_at` datetime(6) NOT NULL,
  `uploaded_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `public_id` (`public_id`),
  KEY `media_assets_uploaded_by_id_cde89776_fk_users_id` (`uploaded_by_id`),
  KEY `media_assets_folder_d153fd79` (`folder`),
  CONSTRAINT `media_assets_uploaded_by_id_cde89776_fk_users_id` FOREIGN KEY (`uploaded_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `negotiated_prices`;
CREATE TABLE `negotiated_prices` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `agreed_price` decimal(10,2) NOT NULL,
  `valid_from` datetime(6) DEFAULT NULL,
  `valid_until` datetime(6) DEFAULT NULL,
  `note` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `created_by_id` bigint(20) DEFAULT NULL,
  `dealer_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `one_negotiated_price_per_dealer_product` (`dealer_id`,`product_id`),
  KEY `negotiated_prices_created_by_id_c6db609e_fk_users_id` (`created_by_id`),
  KEY `negotiated_prices_product_id_2b03569d_fk_products_id` (`product_id`),
  KEY `negotiated__dealer__1f7031_idx` (`dealer_id`,`product_id`),
  CONSTRAINT `negotiated_prices_created_by_id_c6db609e_fk_users_id` FOREIGN KEY (`created_by_id`) REFERENCES `users` (`id`),
  CONSTRAINT `negotiated_prices_dealer_id_398ac2fe_fk_users_id` FOREIGN KEY (`dealer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `negotiated_prices_product_id_2b03569d_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `negotiated_prices` (`id`,`agreed_price`,`valid_from`,`valid_until`,`note`,`created_at`,`updated_at`,`created_by_id`,`dealer_id`,`product_id`) VALUES (1,'1234.50',NULL,NULL,'test','2026-05-13 08:09:30.919259','2026-05-13 08:09:30.919296',6,10,17);

DROP TABLE IF EXISTS `newsletters`;
CREATE TABLE `newsletters` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `subject` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `target_group` varchar(20) NOT NULL,
  `sent_to_emails` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`sent_to_emails`)),
  `sent_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `notification_preferences`;
CREATE TABLE `notification_preferences` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email_order_updates` tinyint(1) NOT NULL,
  `email_marketing` tinyint(1) NOT NULL,
  `sms_order_updates` tinyint(1) NOT NULL,
  `sms_marketing` tinyint(1) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `notification_preferences_user_id_08802827_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `notification_preferences` (`id`,`email_order_updates`,`email_marketing`,`sms_order_updates`,`sms_marketing`,`updated_at`,`user_id`) VALUES (1,1,0,1,0,'2026-05-12 05:08:42.004436',7);
INSERT INTO `notification_preferences` (`id`,`email_order_updates`,`email_marketing`,`sms_order_updates`,`sms_marketing`,`updated_at`,`user_id`) VALUES (2,1,0,1,0,'2026-05-18 08:17:48.479395',14);
INSERT INTO `notification_preferences` (`id`,`email_order_updates`,`email_marketing`,`sms_order_updates`,`sms_marketing`,`updated_at`,`user_id`) VALUES (3,1,0,1,0,'2026-05-23 13:21:13.332918',19);
INSERT INTO `notification_preferences` (`id`,`email_order_updates`,`email_marketing`,`sms_order_updates`,`sms_marketing`,`updated_at`,`user_id`) VALUES (4,1,0,1,0,'2026-05-25 06:23:47.333558',17);

DROP TABLE IF EXISTS `notifications`;
CREATE TABLE `notifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `kind` varchar(40) NOT NULL,
  `title` varchar(200) NOT NULL,
  `body` longtext NOT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`payload`)),
  `is_read` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_kind_06591708` (`kind`),
  KEY `notifications_is_read_27cb7368` (`is_read`),
  KEY `notifications_created_at_878ec15c` (`created_at`),
  KEY `notificatio_user_id_c4e471_idx` (`user_id`,`is_read`,`created_at`),
  CONSTRAINT `notifications_user_id_468e288d_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=92 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (1,'dealer_order_placed','Order ORD-9E68CEEA placed','Hi Dev Dealer,

Your order ORD-9E68CEEA for ?78470.00 has been received. Payment method: razorpay.','{"order_id": "ORD-9E68CEEA", "total": "78470.00", "method": "razorpay"}',0,'2026-05-10 17:13:47.428058',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (2,'admin_dealer_order_placed','New dealer order ORD-9E68CEEA','Dev Dealer (Dev Dealer Co.) placed order ORD-9E68CEEA for ?78470.00 via razorpay.','{"order_id": "ORD-9E68CEEA", "dealer_id": 8, "total": "78470.00", "method": "razorpay", "po_number": ""}',0,'2026-05-10 17:13:52.371431',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (3,'admin_dealer_order_placed','New dealer order ORD-9E68CEEA','Dev Dealer (Dev Dealer Co.) placed order ORD-9E68CEEA for ?78470.00 via razorpay.','{"order_id": "ORD-9E68CEEA", "dealer_id": 8, "total": "78470.00", "method": "razorpay", "po_number": ""}',0,'2026-05-10 17:13:56.593186',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (4,'dealer_order_placed','Order ORD-70AA29AD placed','Hi Dev Dealer,

Your order ORD-70AA29AD for ?78470.00 has been received. Payment method: razorpay.','{"order_id": "ORD-70AA29AD", "total": "78470.00", "method": "razorpay"}',0,'2026-05-10 17:14:07.555735',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (5,'admin_dealer_order_placed','New dealer order ORD-70AA29AD','Dev Dealer (Dev Dealer Co.) placed order ORD-70AA29AD for ?78470.00 via razorpay.','{"order_id": "ORD-70AA29AD", "dealer_id": 8, "total": "78470.00", "method": "razorpay", "po_number": ""}',0,'2026-05-10 17:14:12.154721',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (6,'admin_dealer_order_placed','New dealer order ORD-70AA29AD','Dev Dealer (Dev Dealer Co.) placed order ORD-70AA29AD for ?78470.00 via razorpay.','{"order_id": "ORD-70AA29AD", "dealer_id": 8, "total": "78470.00", "method": "razorpay", "po_number": ""}',0,'2026-05-10 17:14:16.368100',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (7,'dealer_order_placed','Order ORD-8C6215BE placed','Hi Dev Dealer,

Your order ORD-8C6215BE for ?82600.00 has been received. Payment method: cod.','{"order_id": "ORD-8C6215BE", "total": "82600.00", "method": "cod"}',0,'2026-05-10 17:14:37.028093',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (8,'admin_dealer_order_placed','New dealer order ORD-8C6215BE','Dev Dealer (Dev Dealer Co.) placed order ORD-8C6215BE for ?82600.00 via cod.','{"order_id": "ORD-8C6215BE", "dealer_id": 8, "total": "82600.00", "method": "cod", "po_number": ""}',0,'2026-05-10 17:14:41.343641',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (9,'admin_dealer_order_placed','New dealer order ORD-8C6215BE','Dev Dealer (Dev Dealer Co.) placed order ORD-8C6215BE for ?82600.00 via cod.','{"order_id": "ORD-8C6215BE", "dealer_id": 8, "total": "82600.00", "method": "cod", "po_number": ""}',0,'2026-05-10 17:14:45.562091',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (10,'dealer_order_confirmed','Order ORD-8C6215BE ? CONFIRMED','Update on your order ORD-8C6215BE: status is now CONFIRMED.','{"order_id": "ORD-8C6215BE", "status": "CONFIRMED"}',0,'2026-05-11 04:15:03.852082',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (11,'dealer_order_placed','Order ORD-7FE1CBB8 placed','Hi Dev Dealer,

Your order ORD-7FE1CBB8 for ?159177.52 has been received. Payment method: razorpay.','{"order_id": "ORD-7FE1CBB8", "total": "159177.52", "method": "razorpay"}',0,'2026-05-11 04:17:15.359198',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (12,'admin_dealer_order_placed','New dealer order ORD-7FE1CBB8','Dev Dealer (Dev Dealer Co.) placed order ORD-7FE1CBB8 for ?159177.52 via razorpay.','{"order_id": "ORD-7FE1CBB8", "dealer_id": 8, "total": "159177.52", "method": "razorpay", "po_number": ""}',0,'2026-05-11 04:17:19.629487',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (13,'admin_dealer_order_placed','New dealer order ORD-7FE1CBB8','Dev Dealer (Dev Dealer Co.) placed order ORD-7FE1CBB8 for ?159177.52 via razorpay.','{"order_id": "ORD-7FE1CBB8", "dealer_id": 8, "total": "159177.52", "method": "razorpay", "po_number": ""}',0,'2026-05-11 04:17:23.868481',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (14,'dealer_order_placed','Order ORD-3EF34FA6 placed','Hi Dev Dealer,

Your order ORD-3EF34FA6 for ?53808.00 has been received. Payment method: razorpay.','{"order_id": "ORD-3EF34FA6", "total": "53808.00", "method": "razorpay"}',0,'2026-05-11 04:39:04.919670',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (15,'admin_dealer_order_placed','New dealer order ORD-3EF34FA6','Dev Dealer (Dev Dealer Co.) placed order ORD-3EF34FA6 for ?53808.00 via razorpay.','{"order_id": "ORD-3EF34FA6", "dealer_id": 8, "total": "53808.00", "method": "razorpay", "po_number": ""}',0,'2026-05-11 04:39:05.183578',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (16,'admin_dealer_order_placed','New dealer order ORD-3EF34FA6','Dev Dealer (Dev Dealer Co.) placed order ORD-3EF34FA6 for ?53808.00 via razorpay.','{"order_id": "ORD-3EF34FA6", "dealer_id": 8, "total": "53808.00", "method": "razorpay", "po_number": ""}',0,'2026-05-11 04:39:05.288628',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (17,'dealer_order_placed','Order ORD-098807E9 placed','Hi Dev Dealer,

Your order ORD-098807E9 for ?306027.39 has been received. Payment method: razorpay.','{"order_id": "ORD-098807E9", "total": "306027.39", "method": "razorpay"}',0,'2026-05-11 04:40:43.101242',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (18,'admin_dealer_order_placed','New dealer order ORD-098807E9','Dev Dealer (Dev Dealer Co.) placed order ORD-098807E9 for ?306027.39 via razorpay.','{"order_id": "ORD-098807E9", "dealer_id": 8, "total": "306027.39", "method": "razorpay", "po_number": ""}',0,'2026-05-11 04:40:43.314938',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (19,'admin_dealer_order_placed','New dealer order ORD-098807E9','Dev Dealer (Dev Dealer Co.) placed order ORD-098807E9 for ?306027.39 via razorpay.','{"order_id": "ORD-098807E9", "dealer_id": 8, "total": "306027.39", "method": "razorpay", "po_number": ""}',0,'2026-05-11 04:40:43.402252',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (20,'admin_low_stock','Low stock on 1 product(s)','After order ORD-098807E9, the following products are running low:

• 6-Seater Teak Dining Set (SKU DIN-F44E83) — 4 left

Restock soon to avoid backorders.','{"order_id": "ORD-098807E9", "product_ids": [13]}',0,'2026-05-11 04:40:45.144614',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (21,'admin_low_stock','Low stock on 1 product(s)','After order ORD-098807E9, the following products are running low:

• 6-Seater Teak Dining Set (SKU DIN-F44E83) — 4 left

Restock soon to avoid backorders.','{"order_id": "ORD-098807E9", "product_ids": [13]}',0,'2026-05-11 04:40:45.248324',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (22,'dealer_order_confirmed','Order ORD-098807E9 ? CONFIRMED','Update on your order ORD-098807E9: status is now CONFIRMED.','{"order_id": "ORD-098807E9", "status": "CONFIRMED"}',0,'2026-05-11 04:40:48.761488',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (23,'dealer_order_shipped','Order ORD-098807E9 ? SHIPPED','Update on your order ORD-098807E9: status is now SHIPPED.','{"order_id": "ORD-098807E9", "status": "SHIPPED"}',0,'2026-05-11 04:42:02.994970',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (24,'support_ticket_opened','New ticket TKT-2026-00001: hello samir','dev-dealer@furnishop.local opened a normal order ticket.','{"ticket_id": 1, "priority": "normal"}',0,'2026-05-11 05:07:57.985018',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (25,'support_ticket_opened','New ticket TKT-2026-00001: hello samir','dev-dealer@furnishop.local opened a normal order ticket.','{"ticket_id": 1, "priority": "normal"}',0,'2026-05-11 05:07:58.089661',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (26,'support_ticket_opened','New ticket TKT-2026-00002: Order ORD-098807E9 shipped to wrong city','dev-dealer@furnishop.local opened a high shipping ticket.','{"ticket_id": 2, "priority": "high"}',0,'2026-05-11 05:12:25.287911',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (27,'support_ticket_opened','New ticket TKT-2026-00002: Order ORD-098807E9 shipped to wrong city','dev-dealer@furnishop.local opened a high shipping ticket.','{"ticket_id": 2, "priority": "high"}',0,'2026-05-11 05:12:25.451712',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (28,'support_reply','Reply on ticket TKT-2026-00001','why not','{"ticket_id": 1}',0,'2026-05-11 05:13:22.591950',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (29,'support_customer_reply','Customer replied on TKT-2026-00001','okay clos it','{"ticket_id": 1}',0,'2026-05-11 05:14:12.123992',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (30,'support_customer_reply','Customer replied on TKT-2026-00001','okay clos it','{"ticket_id": 1}',0,'2026-05-11 05:14:12.219946',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (31,'admin_low_stock','Low stock on 1 product(s)','After order ORD-8A33872D, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-8A33872D", "product_ids": [17]}',0,'2026-05-11 05:34:27.667737',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (32,'admin_low_stock','Low stock on 1 product(s)','After order ORD-8A33872D, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-8A33872D", "product_ids": [17]}',0,'2026-05-11 05:34:27.773999',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (33,'support_ticket_opened','New ticket TKT-2026-00003: Missing item','dev-dealer@furnishop.local opened a normal order ticket.','{"ticket_id": 3, "priority": "normal"}',0,'2026-05-11 09:07:04.480933',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (34,'support_ticket_opened','New ticket TKT-2026-00003: Missing item','dev-dealer@furnishop.local opened a normal order ticket.','{"ticket_id": 3, "priority": "normal"}',0,'2026-05-11 09:07:04.588834',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (35,'support_reply','Reply on ticket TKT-2026-00003','We are looking into this.','{"ticket_id": 3}',0,'2026-05-11 09:09:58.725986',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (36,'admin_low_stock','Low stock on 1 product(s)','After order ORD-E9C749FD, the following products are running low:

• Test Product XYZ (SKU BED-A5377A) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-E9C749FD", "product_ids": [18]}',0,'2026-05-11 12:21:40.352622',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (37,'admin_low_stock','Low stock on 1 product(s)','After order ORD-E9C749FD, the following products are running low:

• Test Product XYZ (SKU BED-A5377A) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-E9C749FD", "product_ids": [18]}',0,'2026-05-11 12:21:40.444829',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (38,'admin_low_stock','Low stock on 1 product(s)','After order ORD-2BF5E771, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-2BF5E771", "product_ids": [17]}',0,'2026-05-11 14:41:06.445187',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (39,'admin_low_stock','Low stock on 1 product(s)','After order ORD-2BF5E771, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-2BF5E771", "product_ids": [17]}',0,'2026-05-11 14:41:06.551923',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (40,'admin_low_stock','Low stock on 1 product(s)','After order ORD-9896755C, the following products are running low:

• Samir (SKU BED-E908DB) — 5 left

Restock soon to avoid backorders.','{"order_id": "ORD-9896755C", "product_ids": [17]}',0,'2026-05-13 13:30:01.667428',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (41,'admin_low_stock','Low stock on 1 product(s)','After order ORD-9896755C, the following products are running low:

• Samir (SKU BED-E908DB) — 5 left

Restock soon to avoid backorders.','{"order_id": "ORD-9896755C", "product_ids": [17]}',0,'2026-05-13 13:30:01.901632',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (42,'admin_low_stock','Low stock on 1 product(s)','After order ORD-BCD0811D, the following products are running low:

• Samir (SKU BED-E908DB) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-BCD0811D", "product_ids": [17]}',0,'2026-05-13 13:31:20.213762',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (43,'admin_low_stock','Low stock on 1 product(s)','After order ORD-BCD0811D, the following products are running low:

• Samir (SKU BED-E908DB) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-BCD0811D", "product_ids": [17]}',0,'2026-05-13 13:31:20.402190',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (44,'admin_low_stock','Low stock on 1 product(s)','After order ORD-F4762679, the following products are running low:

• Samir (SKU BED-E908DB) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-F4762679", "product_ids": [17]}',0,'2026-05-13 13:31:43.873649',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (45,'admin_low_stock','Low stock on 1 product(s)','After order ORD-F4762679, the following products are running low:

• Samir (SKU BED-E908DB) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-F4762679", "product_ids": [17]}',0,'2026-05-13 13:31:44.062287',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (46,'admin_low_stock','Low stock on 1 product(s)','After order ORD-0D842831, the following products are running low:

• Samir (SKU BED-E908DB) — 1 left

Restock soon to avoid backorders.','{"order_id": "ORD-0D842831", "product_ids": [17]}',0,'2026-05-13 13:32:58.421736',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (47,'admin_low_stock','Low stock on 1 product(s)','After order ORD-0D842831, the following products are running low:

• Samir (SKU BED-E908DB) — 1 left

Restock soon to avoid backorders.','{"order_id": "ORD-0D842831", "product_ids": [17]}',0,'2026-05-13 13:32:58.612928',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (48,'admin_low_stock','Low stock on 1 product(s)','After order ORD-2565507A, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-2565507A", "product_ids": [17]}',0,'2026-05-14 10:36:55.129067',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (49,'admin_low_stock','Low stock on 1 product(s)','After order ORD-2565507A, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-2565507A", "product_ids": [17]}',0,'2026-05-14 10:36:55.314516',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (50,'admin_low_stock','Low stock on 1 product(s)','After order ORD-DCE0DE20, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-DCE0DE20", "product_ids": [17]}',0,'2026-05-14 10:49:10.240969',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (51,'admin_low_stock','Low stock on 1 product(s)','After order ORD-DCE0DE20, the following products are running low:

• Samir (SKU BED-E908DB) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-DCE0DE20", "product_ids": [17]}',0,'2026-05-14 10:49:10.425987',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (52,'support_ticket_opened','New ticket TKT-2026-00005: PRADIP','dev-dealer@furnishop.local opened a high credit ticket.','{"ticket_id": 5, "priority": "high"}',0,'2026-05-18 06:34:53.218269',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (53,'support_ticket_opened','New ticket TKT-2026-00005: PRADIP','dev-dealer@furnishop.local opened a high credit ticket.','{"ticket_id": 5, "priority": "high"}',0,'2026-05-18 06:34:53.419245',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (54,'support_reply','Reply on ticket TKT-2026-00005','OK SOLVED','{"ticket_id": 5}',0,'2026-05-18 06:35:49.821991',8);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (55,'support_ticket_opened','New ticket TKT-2026-00006: Hello','rahulcha@gmail.com opened a high product ticket.','{"ticket_id": 6, "priority": "high"}',0,'2026-05-18 08:28:50.070462',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (56,'support_ticket_opened','New ticket TKT-2026-00006: Hello','rahulcha@gmail.com opened a high product ticket.','{"ticket_id": 6, "priority": "high"}',0,'2026-05-18 08:28:50.258405',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (57,'support_reply','Reply on ticket TKT-2026-00006','Thank you .','{"ticket_id": 6}',0,'2026-05-18 08:30:45.165932',15);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (58,'admin_low_stock','Low stock on 1 product(s)','After order ORD-A736A050, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 4 left

Restock soon to avoid backorders.','{"order_id": "ORD-A736A050", "product_ids": [16]}',0,'2026-05-23 04:37:10.610503',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (59,'admin_low_stock','Low stock on 1 product(s)','After order ORD-A736A050, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 4 left

Restock soon to avoid backorders.','{"order_id": "ORD-A736A050", "product_ids": [16]}',0,'2026-05-23 04:37:10.701862',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (60,'login_otp','Your FurnoTech login code','Hi Harsh,

Your one-time login code is: 390867
It expires in 10 minutes. Do not share it with anyone.','{}',0,'2026-05-23 13:12:06.556963',17);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (61,'support_ticket_opened','New ticket TKT-2026-00007: Is Samir a bad boy','falema3169@nuitx.com opened a high order ticket.','{"ticket_id": 7, "priority": "high"}',0,'2026-05-23 13:22:59.794306',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (62,'support_ticket_opened','New ticket TKT-2026-00007: Is Samir a bad boy','falema3169@nuitx.com opened a high order ticket.','{"ticket_id": 7, "priority": "high"}',0,'2026-05-23 13:23:00.570179',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (63,'support_reply','Reply on ticket TKT-2026-00007','Nothing .','{"ticket_id": 7}',0,'2026-05-23 13:23:54.245775',19);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (64,'admin_low_stock','Low stock on 1 product(s)','After order ORD-03561DFA, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 4 left

Restock soon to avoid backorders.','{"order_id": "ORD-03561DFA", "product_ids": [16]}',0,'2026-05-23 20:59:45.345318',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (65,'admin_low_stock','Low stock on 1 product(s)','After order ORD-03561DFA, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 4 left

Restock soon to avoid backorders.','{"order_id": "ORD-03561DFA", "product_ids": [16]}',0,'2026-05-23 20:59:45.539098',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (66,'admin_account_created','You've been added as an admin on FurnoTech','Hi Fun2,

Dev Admin has added you as an administrator on FurnoTech.

Sign in at https://furnishop-frontend-blond.vercel.app with this email and the password they shared with you.','{}',0,'2026-05-24 03:13:16.696653',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (67,'admin_low_stock','Low stock on 1 product(s)','After order ORD-0BDD8E4C, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-0BDD8E4C", "product_ids": [16]}',0,'2026-05-24 05:35:57.450577',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (68,'admin_low_stock','Low stock on 1 product(s)','After order ORD-0BDD8E4C, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-0BDD8E4C", "product_ids": [16]}',0,'2026-05-24 05:35:57.636622',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (69,'admin_low_stock','Low stock on 1 product(s)','After order ORD-0BDD8E4C, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 3 left

Restock soon to avoid backorders.','{"order_id": "ORD-0BDD8E4C", "product_ids": [16]}',0,'2026-05-24 05:35:57.825846',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (70,'admin_low_stock','Low stock on 1 product(s)','After order ORD-D1F56379, the following products are running low:

• Harsh (SKU TES-03A88F) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-D1F56379", "product_ids": [23]}',0,'2026-05-24 05:39:52.035311',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (71,'admin_low_stock','Low stock on 1 product(s)','After order ORD-D1F56379, the following products are running low:

• Harsh (SKU TES-03A88F) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-D1F56379", "product_ids": [23]}',0,'2026-05-24 05:39:52.221883',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (72,'admin_low_stock','Low stock on 1 product(s)','After order ORD-D1F56379, the following products are running low:

• Harsh (SKU TES-03A88F) — 0 left

Restock soon to avoid backorders.','{"order_id": "ORD-D1F56379", "product_ids": [23]}',0,'2026-05-24 05:39:52.407737',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (73,'admin_low_stock','Low stock on 1 product(s)','After order ORD-42DD6FFC, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-42DD6FFC", "product_ids": [16]}',0,'2026-05-24 05:41:14.370754',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (74,'admin_low_stock','Low stock on 1 product(s)','After order ORD-42DD6FFC, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-42DD6FFC", "product_ids": [16]}',0,'2026-05-24 05:41:14.555505',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (75,'admin_low_stock','Low stock on 1 product(s)','After order ORD-42DD6FFC, the following products are running low:

• Rattan Outdoor Lounge Set (SKU OUT-441F37) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-42DD6FFC", "product_ids": [16]}',0,'2026-05-24 05:41:14.740444',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (76,'login_otp','Your FurnoTech login code','Hi Harsh,

Your one-time login code is: 521209
It expires in 10 minutes. Do not share it with anyone.','{}',0,'2026-05-25 06:23:16.614070',17);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (77,'admin_low_stock','Low stock on 1 product(s)','After order ORD-4E203B5D, the following products are running low:

• Varun (SKU BED-7F32B1) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-4E203B5D", "product_ids": [26]}',0,'2026-05-25 16:54:11.283616',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (78,'admin_low_stock','Low stock on 1 product(s)','After order ORD-4E203B5D, the following products are running low:

• Varun (SKU BED-7F32B1) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-4E203B5D", "product_ids": [26]}',0,'2026-05-25 16:54:11.475883',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (79,'admin_low_stock','Low stock on 1 product(s)','After order ORD-4E203B5D, the following products are running low:

• Varun (SKU BED-7F32B1) — 2 left

Restock soon to avoid backorders.','{"order_id": "ORD-4E203B5D", "product_ids": [26]}',0,'2026-05-25 16:54:11.670607',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (80,'login_otp','Your FurnoTech login code','Hi Harsh,

Your one-time login code is: 364411
It expires in 10 minutes. Do not share it with anyone.','{}',0,'2026-05-26 14:59:34.641252',17);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (81,'login_otp','Your FurnoTech login code','Hi Harsh,

Your one-time login code is: 603273
It expires in 10 minutes. Do not share it with anyone.','{}',0,'2026-05-26 15:01:05.941759',17);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (82,'password_reset','Reset your FurnoTech password','Hi Harsh,

Use the link below to reset your password. It expires in 1 hour.

https://furnishop-frontend-blond.vercel.app/reset-password?token=OH6DEf5DCFpcfzmPgPBnHu1vRba5nJvhAAyttjKWRC0

If you didn't request this, you can ignore this email.','{}',0,'2026-05-26 15:02:45.036133',17);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (83,'support_ticket_opened','New ticket TKT-2026-00008: Test Chatbot Fix','dev-user@furnishop.local opened a normal other ticket.','{"ticket_id": 8, "priority": "normal"}',0,'2026-05-26 15:07:34.301952',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (84,'support_ticket_opened','New ticket TKT-2026-00008: Test Chatbot Fix','dev-user@furnishop.local opened a normal other ticket.','{"ticket_id": 8, "priority": "normal"}',0,'2026-05-26 15:07:35.109366',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (85,'support_ticket_opened','New ticket TKT-2026-00008: Test Chatbot Fix','dev-user@furnishop.local opened a normal other ticket.','{"ticket_id": 8, "priority": "normal"}',0,'2026-05-26 15:07:35.884460',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (86,'support_ticket_opened','New ticket TKT-2026-00009: Final smoke','dev-user@furnishop.local opened a normal other ticket.','{"ticket_id": 9, "priority": "normal"}',0,'2026-05-26 17:07:41.240787',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (87,'support_ticket_opened','New ticket TKT-2026-00009: Final smoke','dev-user@furnishop.local opened a normal other ticket.','{"ticket_id": 9, "priority": "normal"}',0,'2026-05-26 17:07:41.966597',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (88,'support_ticket_opened','New ticket TKT-2026-00009: Final smoke','dev-user@furnishop.local opened a normal other ticket.','{"ticket_id": 9, "priority": "normal"}',0,'2026-05-26 17:07:42.729585',20);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (89,'support_ticket_opened','New ticket TKT-2026-00010: recfvbhub','dev-user@furnishop.local opened a normal order ticket.','{"ticket_id": 10, "priority": "normal"}',0,'2026-05-29 06:42:46.564923',1);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (90,'support_ticket_opened','New ticket TKT-2026-00010: recfvbhub','dev-user@furnishop.local opened a normal order ticket.','{"ticket_id": 10, "priority": "normal"}',0,'2026-05-29 06:42:47.514483',6);
INSERT INTO `notifications` (`id`,`kind`,`title`,`body`,`payload`,`is_read`,`created_at`,`user_id`) VALUES (91,'support_ticket_opened','New ticket TKT-2026-00010: recfvbhub','dev-user@furnishop.local opened a normal order ticket.','{"ticket_id": 10, "priority": "normal"}',0,'2026-05-29 06:42:48.294535',20);

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE `order_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` int(10) unsigned NOT NULL CHECK (`quantity` >= 0),
  `price` decimal(10,2) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `original_price` decimal(10,2) NOT NULL,
  `is_backorder` tinyint(1) NOT NULL,
  `backorder_quantity` int(10) unsigned NOT NULL CHECK (`backorder_quantity` >= 0),
  `expected_restock_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_items_order_id_412ad78b_fk_orders_id` (`order_id`),
  KEY `order_items_product_id_dd557d5a_fk_products_id` (`product_id`),
  KEY `order_items_is_backorder_192140bc` (`is_backorder`),
  CONSTRAINT `order_items_order_id_412ad78b_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `order_items_product_id_dd557d5a_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=57 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (1,1,'19000.00',1,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (2,5,'14000.00',2,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (3,5,'14000.00',3,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (4,5,'14000.00',4,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (5,1,'52999.00',5,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (6,1,'14999.00',5,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (7,2,'36999.00',5,14,'36999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (8,1,'52999.00',6,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (9,1,'14999.00',6,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (10,2,'36999.00',6,14,'36999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (11,1,'24000.00',7,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (12,2,'24000.00',8,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (13,2,'52999.00',9,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (14,1,'14999.00',9,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (15,1,'24000.00',9,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (16,1,'84999.00',9,13,'84999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (17,1,'42999.00',9,12,'42999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (18,6,'24000.00',10,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (19,14,'24000.00',11,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (20,3,'14999.00',12,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (21,2,'36999.00',12,14,'36999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (22,7,'26000.00',13,18,'26000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (23,30,'24000.00',14,17,'24000.00',1,5,'2026-05-25');
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (24,5,'15869.31',15,6,'22999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (25,1,'16560.00',16,17,'24000.00',1,1,'2026-05-27');
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (26,2,'16560.00',17,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (27,2,'16560.00',18,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (28,1,'16560.00',19,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (29,2,'16560.00',20,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (30,1,'16560.00',21,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (31,1,'24000.00',22,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (32,1,'24000.00',23,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (33,1,'16560.00',24,17,'24000.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (34,1,'52999.00',25,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (41,1,'14999.00',33,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (42,1,'36999.00',33,14,'36999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (43,2,'52999.00',34,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (44,2,'31799.40',35,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (45,1,'45999.00',36,1,'45999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (46,1,'14999.00',37,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (47,1,'52999.00',37,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (48,1,'99999.00',38,23,'99999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (49,1,'52999.00',39,16,'52999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (50,1,'14999.00',40,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (51,1,'45999.00',41,1,'45999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (52,1,'45999.00',42,1,'45999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (53,1,'14999.00',43,15,'14999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (54,1,'54123.00',44,26,'54123.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (55,1,'45999.00',45,1,'45999.00',0,0,NULL);
INSERT INTO `order_items` (`id`,`quantity`,`price`,`order_id`,`product_id`,`original_price`,`is_backorder`,`backorder_quantity`,`expected_restock_date`) VALUES (56,1,'45999.00',46,1,'45999.00',0,0,NULL);

DROP TABLE IF EXISTS `order_returns`;
CREATE TABLE `order_returns` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `reason` longtext NOT NULL,
  `status` varchar(10) NOT NULL,
  `refund_amount` decimal(10,2) NOT NULL,
  `admin_note` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `requested_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `order_returns_order_id_b030821a_fk_orders_id` (`order_id`),
  KEY `order_returns_requested_by_id_f2760d2f_fk_users_id` (`requested_by_id`),
  KEY `order_returns_status_5bf07a6c` (`status`),
  CONSTRAINT `order_returns_order_id_b030821a_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `order_returns_requested_by_id_f2760d2f_fk_users_id` FOREIGN KEY (`requested_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `order_id` varchar(20) NOT NULL,
  `user_name` varchar(100) NOT NULL,
  `user_email` varchar(254) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `address` longtext NOT NULL,
  `total_amount` decimal(10,2) NOT NULL,
  `payment_status` varchar(10) NOT NULL,
  `order_status` varchar(12) NOT NULL,
  `erp_order_id` varchar(50) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `erp_sync_status` varchar(10) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `gst_amount` decimal(10,2) NOT NULL,
  `gst_percent` decimal(5,2) NOT NULL,
  `shipping_amount` decimal(10,2) NOT NULL,
  `subtotal_amount` decimal(10,2) NOT NULL,
  `cancellation_reason` longtext NOT NULL,
  `delivered_at` datetime(6) DEFAULT NULL,
  `packing_status` varchar(10) NOT NULL,
  `shipped_at` datetime(6) DEFAULT NULL,
  `shipping_status` varchar(12) NOT NULL,
  `tracking_carrier` varchar(80) NOT NULL,
  `tracking_number` varchar(80) NOT NULL,
  `dealer_note` longtext NOT NULL,
  `payment_method` varchar(20) NOT NULL,
  `po_number` varchar(80) NOT NULL,
  `preferred_carrier` varchar(80) NOT NULL,
  `coupon_code` varchar(40) NOT NULL,
  `coupon_discount` decimal(10,2) NOT NULL,
  `payment_type` varchar(12) NOT NULL,
  `early_payment_discount` decimal(10,2) NOT NULL,
  `billing_company_name` varchar(200) NOT NULL,
  `billing_gstin` varchar(15) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  KEY `orders_user_id_7e2523fb_fk_users_id` (`user_id`),
  KEY `orders_order_status_d7884992` (`order_status`),
  KEY `orders_payment_status_15669208` (`payment_status`),
  KEY `orders_user_email_3e9c853e` (`user_email`),
  KEY `orders_user_em_8db251_idx` (`user_email`),
  KEY `orders_payment_552560_idx` (`payment_status`,`order_status`),
  KEY `orders_packing_status_318551b3` (`packing_status`),
  KEY `orders_shipping_status_fc9c50c9` (`shipping_status`),
  KEY `orders_coupon_code_b990606b` (`coupon_code`),
  KEY `orders_payment_type_a9e42902` (`payment_type`),
  CONSTRAINT `orders_user_id_7e2523fb_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=47 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (1,'ORD-921364B6','Dev User','dev-user@furnishop.local','9876543210','asdfghjkl asdfghjkl; asdfghjkl asdfghjkl','21299.00','SUCCESS','SHIPPED','ERP-SIM-ORD-921364B6','2026-05-10 17:12:12.277733','synced','2026-05-10 17:16:25.491220',7,'3249.00','18.00','0.00','19000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','950.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (2,'ORD-9E68CEEA','Dev Dealer','dev-dealer@furnishop.local','9876543210','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','78470.00','PENDING','CREATED',NULL,'2026-05-10 17:13:47.238365','pending','2026-05-10 17:13:47.238392',8,'11970.00','18.00','0.00','70000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','3500.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (3,'ORD-70AA29AD','Dev Dealer','dev-dealer@furnishop.local','9876543210','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','78470.00','PENDING','CREATED',NULL,'2026-05-10 17:14:07.457823','pending','2026-05-10 17:14:07.457867',8,'11970.00','18.00','0.00','70000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','3500.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (4,'ORD-8C6215BE','Dev Dealer','dev-dealer@furnishop.local','9876543211','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','82600.00','PENDING','CONFIRMED',NULL,'2026-05-10 17:14:36.932957','pending','2026-05-11 04:15:03.631426',8,'12600.00','18.00','0.00','70000.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (5,'ORD-7FE1CBB8','Dev Dealer','dev-dealer@furnishop.local','9876543211','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','159177.52','PENDING','CREATED',NULL,'2026-05-11 04:17:15.247028','pending','2026-05-11 04:17:15.247142',8,'24281.32','18.00','0.00','141996.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','7099.80','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (6,'ORD-5CD300C9','deeke','deeke@gmail.com','9876543210','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','159177.52','SUCCESS','CONFIRMED','INT-ORD-5CD300C9','2026-05-11 04:25:02.669780','synced','2026-05-11 04:25:02.669807',NULL,'24281.32','18.00','0.00','141996.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','7099.80','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (7,'ORD-A8FF7E20','Guest Tester','guest+test@example.com','9876543210','42 Test Lane, Mumbai, MH 400001','26904.00','SUCCESS','CONFIRMED','INT-ORD-A8FF7E20','2026-05-11 04:38:11.946931','synced','2026-05-11 04:38:11.946963',NULL,'4104.00','18.00','0.00','24000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','1200.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (8,'ORD-3EF34FA6','Dev Dealer','dev-dealer@furnishop.local','9876543210','Dealer Address, 42 Test Lane, Nagpur, MH 440001','53808.00','PENDING','CANCELLED',NULL,'2026-05-11 04:39:04.817204','pending','2026-05-11 18:03:08.713977',8,'8208.00','18.00','0.00','48000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','2400.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (9,'ORD-098807E9','Dev Dealer','dev-dealer@furnishop.local','9876543210','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','306027.39','SUCCESS','SHIPPED','INT-ORD-098807E9','2026-05-11 04:40:43.001621','synced','2026-05-11 04:42:02.408347',8,'46682.14','18.00','0.00','272995.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','13649.75','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (10,'ORD-F15742A0','Dev User','dev-user@furnishop.local','9876543210','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','161424.00','SUCCESS','CONFIRMED','INT-ORD-F15742A0','2026-05-11 05:32:26.093576','synced','2026-05-11 05:32:26.093855',7,'24624.00','18.00','0.00','144000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','7200.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (11,'ORD-8A33872D','Dev User','dev-user@furnishop.local','9876543210','asdfghjkl asdfghjkl asdfghjkl asdfghjkl','376656.00','SUCCESS','CONFIRMED','INT-ORD-8A33872D','2026-05-11 05:34:27.145119','synced','2026-05-11 05:34:27.145439',7,'57456.00','18.00','0.00','336000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','16800.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (12,'ORD-6CAA0E89','Test User Functional','testfunc@example.com','9876543210','123 Test Street, Apt 4B, Mumbai, Maharashtra','140414.10','SUCCESS','SHIPPED','INT-ORD-6CAA0E89','2026-05-11 08:28:17.467162','synced','2026-05-11 08:41:52.205955',NULL,'21419.10','18.00','0.00','118995.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (13,'ORD-E9C749FD','Dev Dealer','dev-dealer@furnishop.local','9876543210','sdfghjhgf sdfghjhgfd sdfghjhgfd sdfghjhgfd','214760.00','SUCCESS','CONFIRMED','INT-ORD-E9C749FD','2026-05-11 12:21:39.450446','synced','2026-05-11 12:21:39.450483',8,'32760.00','18.00','0.00','182000.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (14,'ORD-2BF5E771','Dev Dealer','dev-dealer@furnishop.local','9876543210','sdfghjk asdfghjkl asdfghjkl asdfghjk','807120.00','SUCCESS','DELIVERED','INT-ORD-2BF5E771','2026-05-11 14:41:05.403377','synced','2026-05-14 11:41:05.142096',8,'123120.00','18.00','0.00','720000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','36000.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (15,'ORD-424A0E25','Dev Dealer','dev-dealer@furnishop.local','9876543210','123 Dealer St, FurniCity','93628.93','SUCCESS','CONFIRMED','INT-ORD-424A0E25','2026-05-12 16:31:32.844654','synced','2026-05-12 16:31:32.844768',8,'14282.38','18.00','0.00','79346.55','',NULL,'pending',NULL,'not_shipped','','','','credit','','','','0.00','credit','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (16,'ORD-B076EBCE','Dev Dealer','dev-dealer@furnishop.local','9876543210','Test addr Nagpur 440001','18563.76','PENDING','CREATED',NULL,'2026-05-13 08:09:35.145429','pending','2026-05-13 08:09:35.145494',8,'2831.76','18.00','0.00','16560.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','828.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (17,'ORD-1A19834B','Dev Dealer','dev-dealer@furnishop.local','9876543210','Test Address Nagpur 440001','37127.52','PENDING','CREATED',NULL,'2026-05-13 13:18:50.852417','pending','2026-05-13 13:18:50.852449',8,'5663.52','18.00','0.00','33120.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','1656.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (18,'ORD-FEA58B40','Dev Dealer','dev-dealer@furnishop.local','9876543210','Test Address Nagpur 440001','37127.52','SUCCESS','CONFIRMED','INT-ORD-FEA58B40','2026-05-13 13:29:38.257105','synced','2026-05-13 13:29:38.257139',8,'5663.52','18.00','0.00','33120.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','1656.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (19,'ORD-9896755C','Dev Dealer','dev-dealer@furnishop.local','9876543210','Test Address Nagpur 440001','19540.80','PENDING','CREATED',NULL,'2026-05-13 13:29:59.942741','pending','2026-05-13 13:29:59.942771',8,'2980.80','18.00','0.00','16560.00','',NULL,'pending',NULL,'not_shipped','','','','credit','','','','0.00','credit','0.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (20,'ORD-BCD0811D','Dev Dealer','dev-dealer@furnishop.local','9876543210','Test Address Nagpur 440001','37127.52','SUCCESS','CONFIRMED','INT-ORD-BCD0811D','2026-05-13 13:31:18.508119','synced','2026-05-13 13:31:18.508151',8,'5663.52','18.00','0.00','33120.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','1656.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (21,'ORD-F4762679','Dev Dealer','dev-dealer@furnishop.local','9876543210','Test Address Nagpur 440001','19540.80','PENDING','CREATED',NULL,'2026-05-13 13:31:42.174321','pending','2026-05-13 13:31:42.174351',8,'2980.80','18.00','0.00','16560.00','',NULL,'pending',NULL,'not_shipped','','','','credit','','','','0.00','credit','0.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (22,'ORD-0D842831','Dev User','dev-user@furnishop.local','9876543210','Test 12 MG Road Mumbai 400001','26904.00','SUCCESS','DELIVERED','INT-ORD-0D842831','2026-05-13 13:32:57.499294','synced','2026-05-18 06:29:45.168236',7,'4104.00','18.00','0.00','24000.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','1200.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (23,'ORD-2565507A','Dev User','dev-user@furnishop.local','8208967150','Khapri(uma)xvxvdfvdfvbzvdj,mdf vd.vkbdvbdf','26904.00','FAILED','CANCELLED','INT-ORD-2565507A','2026-05-14 10:36:54.198779','synced','2026-05-14 10:38:18.320306',7,'4104.00','18.00','0.00','24000.00','xgdfdfdf',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','1200.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (24,'ORD-DCE0DE20','Dev Dealer','dev-dealer@furnishop.local','8208967150','Khapri(uma)sdfsdfnsdfkjsdfsdkfsdf','18563.76','SUCCESS','DELIVERED','INT-ORD-DCE0DE20','2026-05-14 10:49:08.517726','synced','2026-05-14 11:39:16.672553',8,'2831.76','18.00','0.00','16560.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','828.00','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (25,'ORD-34146118','Rahul Chawla','rahul@gmail.com','9876543210','asdfghjkl asdfghjk asdfghjkl','29705.93','SUCCESS','CONFIRMED','INT-ORD-34146118','2026-05-18 08:15:25.405882','synced','2026-05-18 08:15:25.405924',14,'4531.41','18.00','0.00','52999.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','TEST50','26499.50','immediate','1324.98','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (33,'ORD-3C19F187','Dev User','dev-user@furnishop.local','9876543210','dsjkkkkkkkks, ASDFGGHJ, ghjksdjfhds vghjasdhfgdhjsk, dhfvdhjsshdhfj, Mumbai, Maharashtra, 560001','58289.76','SUCCESS','CONFIRMED','INT-ORD-3C19F187','2026-05-23 04:32:52.425532','synced','2026-05-23 04:32:52.425585',7,'8891.66','18.00','0.00','51998.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','2599.90','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (34,'ORD-A736A050','Dev User','dev-user@furnishop.local','9876543210','dsjkkkkkkkks, ASDFGGHJ, ghjksdjfhds vghjasdhfgdhjsk, dhfvdhjsshdhfj, Mumbai, Maharashtra, 440010','118823.76','PENDING','CANCELLED',NULL,'2026-05-23 04:37:10.160322','pending','2026-05-23 04:38:29.590154',7,'18125.66','18.00','0.00','105998.00','because i dont want this',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','5299.90','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (35,'ORD-03561DFA','Dev Dealer','dev-dealer@furnishop.local','9876543210','asdfghj, ASDFGHJKL ASDFGHJKL ASDFGHJKL;, asdfghjkl; asdfghjklasdfghjk, sdfghjkl;, asdfghjkl, 441111','71294.25','PENDING','CREATED',NULL,'2026-05-23 20:59:41.687645','pending','2026-05-23 20:59:41.687675',8,'10875.39','18.00','0.00','63598.80','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','3179.94','Dev Dealer Co.','29ABCDE1234F1Z5');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (36,'ORD-3FC6FB37','Test Buyer','dev-user@furnishop.local','9999999999','123 Test Street, Mumbai 400001','51564.88','PENDING','CONFIRMED',NULL,'2026-05-24 02:40:58.536268','pending','2026-05-24 03:15:52.848401',7,'7865.83','18.00','0.00','45999.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','2299.95','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (37,'ORD-0BDD8E4C','Dev User','dev-user@furnishop.local','8208967150','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','76225.76','PENDING','CREATED',NULL,'2026-05-24 05:35:55.956072','pending','2026-05-24 05:35:55.956102',7,'11627.66','18.00','0.00','67998.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','3399.90','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (38,'ORD-D1F56379','Dev User','dev-user@furnishop.local','8208967150','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','117998.82','PENDING','CREATED',NULL,'2026-05-24 05:39:51.106861','pending','2026-05-24 05:39:51.106892',7,'17999.82','18.00','0.00','99999.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (39,'ORD-42DD6FFC','Dev User','dev-user@furnishop.local','8208967150','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','62538.82','PENDING','CREATED',NULL,'2026-05-24 05:41:13.445125','pending','2026-05-24 05:41:13.445155',7,'9539.82','18.00','0.00','52999.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (40,'ORD-3B954F01','Dev User','dev-user@furnishop.local','9876543210','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','17698.82','SUCCESS','CONFIRMED','INT-ORD-3B954F01','2026-05-25 06:39:33.674953','synced','2026-05-25 06:39:33.674989',7,'2699.82','18.00','0.00','14999.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (41,'ORD-1ED61036','Smoke Test','dev-user@furnishop.local','9999999999','42 Smoke St Mumbai 400001','54278.82','PENDING','CONFIRMED','INT-ORD-1ED61036','2026-05-25 07:07:17.674881','synced','2026-05-25 07:07:17.674917',7,'8279.82','18.00','0.00','45999.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (42,'ORD-0534624A','RZ Test','dev-user@furnishop.local','9999999999','42 X','51564.88','PENDING','CREATED',NULL,'2026-05-25 07:07:26.034219','pending','2026-05-25 07:07:26.034260',7,'7865.83','18.00','0.00','45999.00','',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','2299.95','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (43,'ORD-DB9796EB','Samir Ganesh Watgule','sameer2004watgule@gmail.com','8208967150','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','17698.82','FAILED','CANCELLED','INT-ORD-DB9796EB','2026-05-25 15:58:05.288803','synced','2026-05-25 16:00:22.243038',21,'2699.82','18.00','0.00','14999.00','Cancelled by buyer.',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (44,'ORD-4E203B5D','Samir Ganesh Watgule','sameer2004watgule@gmail.com','8208967150','zxcvbnmcvbnm,ghjkkjhgfxcvbnkjhgvc, vbngfedfvhbnm, Nagpur, Maharashtra, 441501','30335.94','FAILED','CANCELLED','INT-ORD-4E203B5D','2026-05-25 16:54:10.316820','synced','2026-05-25 16:58:36.615197',21,'4627.52','18.00','0.00','54123.00','Cancelled by buyer.',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','TEST50','27061.50','immediate','1353.08','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (45,'ORD-95D115F0','Final Test','dev-user@furnishop.local','9999999999','42 X Mumbai 400001','54278.82','PENDING','SHIPPED','INT-ORD-95D115F0','2026-05-26 17:07:08.183715','synced','2026-05-29 06:50:31.395144',7,'8279.82','18.00','0.00','45999.00','',NULL,'pending',NULL,'not_shipped','','','','cod','','','','0.00','cod','0.00','','');
INSERT INTO `orders` (`id`,`order_id`,`user_name`,`user_email`,`phone`,`address`,`total_amount`,`payment_status`,`order_status`,`erp_order_id`,`created_at`,`erp_sync_status`,`updated_at`,`user_id`,`gst_amount`,`gst_percent`,`shipping_amount`,`subtotal_amount`,`cancellation_reason`,`delivered_at`,`packing_status`,`shipped_at`,`shipping_status`,`tracking_carrier`,`tracking_number`,`dealer_note`,`payment_method`,`po_number`,`preferred_carrier`,`coupon_code`,`coupon_discount`,`payment_type`,`early_payment_discount`,`billing_company_name`,`billing_gstin`) VALUES (46,'ORD-3DB61DEC','RZ Test','dev-user@furnishop.local','9999999999','X','51564.88','PENDING','CANCELLED',NULL,'2026-05-26 17:07:18.668018','pending','2026-05-26 17:07:35.762700',7,'7865.83','18.00','0.00','45999.00','test',NULL,'pending',NULL,'not_shipped','','','','razorpay','','','','0.00','immediate','2299.95','','');

DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` varchar(64) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `used_at` datetime(6) DEFAULT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token` (`token`),
  KEY `password_reset_tokens_user_id_0aeaaad3_fk_users_id` (`user_id`),
  CONSTRAINT `password_reset_tokens_user_id_0aeaaad3_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `password_reset_tokens` (`id`,`token`,`created_at`,`expires_at`,`used_at`,`user_id`) VALUES (1,'OH6DEf5DCFpcfzmPgPBnHu1vRba5nJvhAAyttjKWRC0','2026-05-26 15:02:44.838284','2026-05-26 16:02:44.837854',NULL,17);

DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `razorpay_order_id` varchar(100) DEFAULT NULL,
  `razorpay_payment_id` varchar(100) DEFAULT NULL,
  `status` varchar(10) NOT NULL,
  `amount` decimal(10,2) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `failure_reason` longtext DEFAULT NULL,
  `razorpay_signature` varchar(256) DEFAULT NULL,
  `updated_at` datetime(6) NOT NULL,
  `email_sent_at` datetime(6) DEFAULT NULL,
  `sms_sent_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`),
  CONSTRAINT `payments_order_id_6086ad70_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (1,NULL,NULL,'SUCCESS','21299.00','2026-05-10 17:12:13.460877',1,NULL,NULL,'2026-05-10 17:12:13.743662',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (2,NULL,NULL,'SUCCESS','159177.52','2026-05-11 04:25:04.819429',6,NULL,NULL,'2026-05-11 04:25:05.126823',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (3,NULL,NULL,'SUCCESS','26904.00','2026-05-11 04:38:31.180256',7,NULL,NULL,'2026-05-11 04:38:31.470199',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (4,NULL,NULL,'SUCCESS','306027.39','2026-05-11 04:40:46.530847',9,NULL,NULL,'2026-05-11 04:40:46.848493',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (5,NULL,NULL,'SUCCESS','161424.00','2026-05-11 05:32:27.421470',10,NULL,NULL,'2026-05-11 05:32:27.685518',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (6,NULL,NULL,'SUCCESS','376656.00','2026-05-11 05:34:28.845073',11,NULL,NULL,'2026-05-11 05:34:29.128784',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (7,NULL,NULL,'SUCCESS','140414.10','2026-05-11 08:28:19.289379',12,NULL,NULL,'2026-05-11 08:28:19.652267',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (8,NULL,NULL,'SUCCESS','214760.00','2026-05-11 12:21:41.970404',13,NULL,NULL,'2026-05-11 12:21:42.209702',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (9,NULL,NULL,'SUCCESS','807120.00','2026-05-11 14:41:09.068030',14,NULL,NULL,'2026-05-11 14:41:09.366262',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (10,NULL,NULL,'SUCCESS','93628.93','2026-05-12 16:31:38.735361',15,NULL,NULL,'2026-05-12 16:31:39.119424',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (11,NULL,NULL,'SUCCESS','37127.52','2026-05-13 13:29:42.731220',18,NULL,NULL,'2026-05-13 13:29:43.292751',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (12,NULL,NULL,'SUCCESS','37127.52','2026-05-13 13:31:23.614681',20,NULL,NULL,'2026-05-13 13:31:24.175751',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (13,NULL,NULL,'SUCCESS','26904.00','2026-05-13 13:33:00.918439',22,NULL,NULL,'2026-05-13 13:33:01.482814',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (14,NULL,NULL,'SUCCESS','26904.00','2026-05-14 10:36:57.788348',23,NULL,NULL,'2026-05-14 10:36:58.380216',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (15,NULL,NULL,'SUCCESS','18563.76','2026-05-14 10:49:12.512255',24,NULL,NULL,'2026-05-14 10:49:13.087896',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (16,NULL,NULL,'SUCCESS','29705.93','2026-05-18 08:15:29.434284',25,NULL,NULL,'2026-05-18 08:15:29.997907',NULL,NULL);
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (19,NULL,NULL,'SUCCESS','58289.76','2026-05-23 04:32:54.875904',33,NULL,NULL,'2026-05-23 04:32:55.131751','2026-05-23 04:32:59.911267','2026-05-23 04:33:00.007007');
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (20,NULL,NULL,'SUCCESS','17698.82','2026-05-25 06:39:39.274875',40,NULL,NULL,'2026-05-25 06:39:39.852845','2026-05-25 06:39:46.208075','2026-05-25 06:39:46.401931');
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (21,NULL,NULL,'PENDING','54278.82','2026-05-25 07:07:19.575037',41,NULL,NULL,'2026-05-25 07:07:19.575078','2026-05-25 07:07:21.531129','2026-05-25 07:07:21.722027');
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (22,NULL,NULL,'SUCCESS','17698.82','2026-05-25 15:58:07.156540',43,NULL,NULL,'2026-05-25 15:58:11.883056','2026-05-25 15:58:09.176500','2026-05-25 15:58:09.363299');
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (23,'order_StfblV2H1myP2C','pay_StfdVpo6onHwIK','SUCCESS','30335.94','2026-05-25 16:56:37.051314',44,NULL,'7d500e3b58502d97fe8dd90610b73598d16c0c9ffbd68104dfce356edf654763','2026-05-25 16:56:37.641666','2026-05-25 16:56:44.146449','2026-05-25 16:56:44.345929');
INSERT INTO `payments` (`id`,`razorpay_order_id`,`razorpay_payment_id`,`status`,`amount`,`created_at`,`order_id`,`failure_reason`,`razorpay_signature`,`updated_at`,`email_sent_at`,`sms_sent_at`) VALUES (24,NULL,NULL,'PENDING','54278.82','2026-05-26 17:07:10.012933',45,NULL,NULL,'2026-05-26 17:07:10.012966','2026-05-26 17:07:11.918293','2026-05-26 17:07:12.100870');

DROP TABLE IF EXISTS `product_delivery_rules`;
CREATE TABLE `product_delivery_rules` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `min_qty` int(10) unsigned NOT NULL CHECK (`min_qty` >= 0),
  `max_qty` int(10) unsigned NOT NULL CHECK (`max_qty` >= 0),
  `etd_days_min` smallint(5) unsigned NOT NULL CHECK (`etd_days_min` >= 0),
  `etd_days_max` smallint(5) unsigned NOT NULL CHECK (`etd_days_max` >= 0),
  `note` varchar(160) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_del_product_ffea0f_idx` (`product_id`,`min_qty`),
  CONSTRAINT `product_delivery_rules_product_id_306ada37_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `product_media`;
CREATE TABLE `product_media` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `kind` varchar(8) NOT NULL,
  `file` varchar(255) DEFAULT NULL,
  `is_primary` tinyint(1) NOT NULL,
  `order` int(10) unsigned NOT NULL CHECK (`order` >= 0),
  `alt_text` varchar(200) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_med_product_970759_idx` (`product_id`,`is_primary`),
  CONSTRAINT `product_media_product_id_da264f78_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=28 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (3,'image','furnishop/products/rattan-outdoor-lounge-set/main',1,0,'Rattan Outdoor Lounge Set','2026-05-20 06:22:29.177840',16);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (4,'image','furnishop/products/teak-garden-bench/main',1,0,'Teak Garden Bench','2026-05-20 06:22:33.304969',15);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (5,'image','furnishop/products/compact-4-seater-dining-set/main',1,0,'Compact 4-Seater Dining Set','2026-05-20 06:22:36.325518',14);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (6,'image','furnishop/products/6-seater-teak-dining-set/main',1,0,'6-Seater Teak Dining Set','2026-05-20 06:22:40.694645',13);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (7,'image','furnishop/products/height-adjustable-standing-desk/main',1,0,'Height Adjustable Standing Desk','2026-05-20 06:22:45.330083',12);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (8,'image','furnishop/products/solid-oak-writing-desk/main',1,0,'Solid Oak Writing Desk','2026-05-20 06:22:53.172718',11);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (9,'image','furnishop/products/3-door-wardrobe/main',1,0,'3-Door Wardrobe','2026-05-20 06:22:59.416255',10);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (10,'image','furnishop/products/modular-bookshelf-unit/main',1,0,'Modular Bookshelf Unit','2026-05-20 06:23:02.512212',9);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (11,'image','furnishop/products/upholstered-wingback-bed/main',1,0,'Upholstered Wingback Bed','2026-05-20 06:23:06.298244',8);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (12,'image','furnishop/products/king-platform-bed-frame/main',1,0,'King Platform Bed Frame','2026-05-20 06:23:09.168017',7);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (13,'image','furnishop/products/ergonomic-mesh-office-chair/main',1,0,'Ergonomic Mesh Office Chair','2026-05-20 06:23:11.936445',6);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (15,'image','furnishop/products/marble-top-dining-table/main',1,0,'Marble Top Dining Table','2026-05-20 06:23:17.603997',4);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (16,'image','furnishop/products/acacia-wood-coffee-table/main',1,0,'Acacia Wood Coffee Table','2026-05-20 06:23:20.114085',3);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (17,'image','furnishop/products/nordic-l-shape-sectional/main',1,0,'Nordic L-Shape Sectional','2026-05-20 06:23:22.776512',2);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (18,'image','furnishop/products/oslo-velvet-sofa/main',1,0,'Oslo Velvet Sofa','2026-05-20 06:23:25.409696',1);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (19,'image','furnishop/products/tulip-accent-chair/main',1,0,'Tulip Accent Chair','2026-05-20 06:54:39.970858',5);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (24,'image','furnishop/products/harsh/111_hl0bgi',1,0,'','2026-05-23 20:17:33.567687',23);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (25,'image','furnishop/products/harsh/112_napvgs',0,1,'','2026-05-23 20:17:35.052719',23);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (26,'image','furnishop/products/harsh/113_mlrd8h',0,2,'','2026-05-23 20:17:36.639212',23);
INSERT INTO `product_media` (`id`,`kind`,`file`,`is_primary`,`order`,`alt_text`,`created_at`,`product_id`) VALUES (27,'image','furnishop/products/harsh/114_rxyvjg',0,3,'','2026-05-23 20:17:38.037255',23);

DROP TABLE IF EXISTS `product_specifications`;
CREATE TABLE `product_specifications` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `label` varchar(100) NOT NULL,
  `value` varchar(200) NOT NULL,
  `sort_order` int(10) unsigned NOT NULL CHECK (`sort_order` >= 0),
  `product_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `product_specifications_product_id_17d3589e_fk_products_id` (`product_id`),
  CONSTRAINT `product_specifications_product_id_17d3589e_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `product_specifications` (`id`,`label`,`value`,`sort_order`,`product_id`) VALUES (9,'Battery Backup','2% after midnight',0,23);
INSERT INTO `product_specifications` (`id`,`label`,`value`,`sort_order`,`product_id`) VALUES (10,'Operating System','HarshOS v2.0',1,23);
INSERT INTO `product_specifications` (`id`,`label`,`value`,`sort_order`,`product_id`) VALUES (11,'nfhnhffh','5125',0,26);

DROP TABLE IF EXISTS `product_stock_alerts`;
CREATE TABLE `product_stock_alerts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `notified` tinyint(1) NOT NULL,
  `notified_at` datetime(6) DEFAULT NULL,
  `product_id` bigint(20) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `product_stock_alerts_user_id_5b9176ee_fk_users_id` (`user_id`),
  KEY `product_sto_product_a1cea4_idx` (`product_id`,`notified`),
  KEY `product_stock_alerts_email_b88487e3` (`email`),
  KEY `product_stock_alerts_notified_6664c8c0` (`notified`),
  CONSTRAINT `product_stock_alerts_product_id_d8ca8c84_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `product_stock_alerts_user_id_5b9176ee_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `product_stock_alerts` (`id`,`email`,`created_at`,`notified`,`notified_at`,`product_id`,`user_id`) VALUES (1,'test@example.com','2026-05-13 08:09:24.431552',0,NULL,17,NULL);
INSERT INTO `product_stock_alerts` (`id`,`email`,`created_at`,`notified`,`notified_at`,`product_id`,`user_id`) VALUES (2,'harshchakravarti77@gmail.com','2026-05-25 06:21:37.661614',0,NULL,23,NULL);
INSERT INTO `product_stock_alerts` (`id`,`email`,`created_at`,`notified`,`notified_at`,`product_id`,`user_id`) VALUES (3,'sameer2004watgule@gmail.com','2026-05-25 16:24:14.891086',0,NULL,23,21);

DROP TABLE IF EXISTS `product_tags`;
CREATE TABLE `product_tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `slug` varchar(100) NOT NULL,
  `description` varchar(200) NOT NULL,
  `is_navigation` tinyint(1) NOT NULL,
  `nav_label` varchar(80) NOT NULL,
  `nav_order` int(10) unsigned NOT NULL CHECK (`nav_order` >= 0),
  `created_at` datetime(6) NOT NULL,
  `category_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `slug` (`slug`),
  KEY `product_tags_is_navigation_bd07c1c2` (`is_navigation`),
  KEY `product_tag_is_navi_8d25ac_idx` (`is_navigation`,`nav_order`),
  KEY `product_tag_categor_50cfc0_idx` (`category_id`,`is_navigation`),
  CONSTRAINT `product_tags_category_id_bbdad34b_fk_categories_id` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `product_tags` (`id`,`name`,`slug`,`description`,`is_navigation`,`nav_label`,`nav_order`,`created_at`,`category_id`) VALUES (1,'test-keyword-alpha','test-keyword-alpha','',0,'',0,'2026-05-24 03:28:04.533376',NULL);
INSERT INTO `product_tags` (`id`,`name`,`slug`,`description`,`is_navigation`,`nav_label`,`nav_order`,`created_at`,`category_id`) VALUES (2,'test-keyword-beta','test-keyword-beta','',0,'',0,'2026-05-24 03:28:04.905320',NULL);
INSERT INTO `product_tags` (`id`,`name`,`slug`,`description`,`is_navigation`,`nav_label`,`nav_order`,`created_at`,`category_id`) VALUES (3,'multipart-tag-x','multipart-tag-x','',0,'',0,'2026-05-24 03:28:24.749551',NULL);
INSERT INTO `product_tags` (`id`,`name`,`slug`,`description`,`is_navigation`,`nav_label`,`nav_order`,`created_at`,`category_id`) VALUES (4,'multipart-tag-y','multipart-tag-y','',0,'',0,'2026-05-24 03:28:25.134824',NULL);
INSERT INTO `product_tags` (`id`,`name`,`slug`,`description`,`is_navigation`,`nav_label`,`nav_order`,`created_at`,`category_id`) VALUES (5,'Prestino Director Table','prestino-director-table','',0,'',0,'2026-05-24 04:06:17.737761',NULL);

DROP TABLE IF EXISTS `product_variants`;
CREATE TABLE `product_variants` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `sku` varchar(40) NOT NULL,
  `option_name` varchar(50) NOT NULL,
  `option_value` varchar(50) NOT NULL,
  `price_delta` decimal(10,2) NOT NULL,
  `stock` int(10) unsigned NOT NULL CHECK (`stock` >= 0),
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sku` (`sku`),
  UNIQUE KEY `product_variants_product_id_option_name_o_21b5fcf1_uniq` (`product_id`,`option_name`,`option_value`),
  CONSTRAINT `product_variants_product_id_019d9f04_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(200) NOT NULL,
  `slug` varchar(200) NOT NULL,
  `description` longtext NOT NULL,
  `price` decimal(10,2) NOT NULL,
  `material` varchar(50) NOT NULL,
  `color` varchar(50) NOT NULL,
  `dimensions` varchar(100) NOT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `stock` int(10) unsigned NOT NULL CHECK (`stock` >= 0),
  `created_at` datetime(6) NOT NULL,
  `category_id` bigint(20) NOT NULL,
  `is_featured` tinyint(1) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `sku` varchar(32) NOT NULL,
  `status` varchar(10) NOT NULL,
  `brand` varchar(80) NOT NULL,
  `deleted_at` datetime(6) DEFAULT NULL,
  `delivery_estimate_days` int(10) unsigned NOT NULL CHECK (`delivery_estimate_days` >= 0),
  `highlights` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`highlights`)),
  `hsn_code` varchar(10) NOT NULL,
  `is_deleted` tinyint(1) NOT NULL,
  `meta_description` varchar(320) NOT NULL,
  `meta_title` varchar(160) NOT NULL,
  `og_image_url` varchar(500) NOT NULL,
  `rating_avg` decimal(3,2) NOT NULL,
  `rating_count` int(10) unsigned NOT NULL CHECK (`rating_count` >= 0),
  `weight_grams` int(10) unsigned DEFAULT NULL CHECK (`weight_grams` >= 0),
  `dealer_only` tinyint(1) NOT NULL,
  `min_order_quantity` int(10) unsigned NOT NULL CHECK (`min_order_quantity` >= 0),
  `short_description` varchar(240) NOT NULL,
  `feature_blocks` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`feature_blocks`)),
  `perks` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`perks`)),
  `youtube_url` varchar(500) NOT NULL,
  `warranty_years` smallint(5) unsigned NOT NULL CHECK (`warranty_years` >= 0),
  `installation_required` tinyint(1) NOT NULL,
  `care_instructions` longtext NOT NULL,
  `return_policy_days` smallint(5) unsigned NOT NULL CHECK (`return_policy_days` >= 0),
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  UNIQUE KEY `products_sku_81b9e9fe_uniq` (`sku`),
  KEY `products_categor_4083ff_idx` (`category_id`),
  KEY `products_materia_a1405d_idx` (`material`),
  KEY `products_price_fe467e_idx` (`price`),
  KEY `products_status_a30e64_idx` (`status`),
  KEY `products_sku_81b9e9fe` (`sku`),
  KEY `products_status_70b83b5a` (`status`),
  KEY `products_brand_d3f3629a` (`brand`),
  KEY `products_is_deleted_4362abbb` (`is_deleted`),
  KEY `products_dealer_only_64e0d9d3` (`dealer_only`),
  CONSTRAINT `products_category_id_a7a3a156_fk_categories_id` FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (1,'Oslo Velvet Sofa','oslo-velvet-sofa','Premium 3-seater velvet sofa with solid oak legs. Mid-century modern design that brings timeless elegance to your living room.','45999.00','fabric','Emerald Green','220x85x80 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258204/furnishop/products/oslo-velvet-sofa/main.jpg',11,'2026-05-10 15:59:05.431708',1,1,'2026-05-10 15:59:05.431756','SOF-B2D63A','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (2,'Nordic L-Shape Sectional','nordic-l-shape-sectional','Spacious L-shaped sectional sofa with removable covers. Perfect for large living rooms and open-plan spaces.','78999.00','fabric','Charcoal Grey','300x200x80 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258202/furnishop/products/nordic-l-shape-sectional/main.jpg',8,'2026-05-10 15:59:07.021882',1,0,'2026-05-10 15:59:07.021915','SOF-D6E8B9','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (3,'Acacia Wood Coffee Table','acacia-wood-coffee-table','Hand-crafted solid acacia wood coffee table with natural grain finish. Each piece is unique.','18999.00','wood','Natural Brown','120x60x45 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258199/furnishop/products/acacia-wood-coffee-table/main.jpg',22,'2026-05-10 15:59:08.725460',2,0,'2026-05-10 15:59:08.725505','TAB-C6B504','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (4,'Marble Top Dining Table','marble-top-dining-table','Luxurious white marble dining table with powder-coated steel frame. Seats 6 comfortably.','54999.00','marble','White','180x90x75 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258197/furnishop/products/marble-top-dining-table/main.jpg',10,'2026-05-10 15:59:11.788953',2,1,'2026-05-10 15:59:11.789013','TAB-EE6A9D','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (5,'Tulip Accent Chair','tulip-accent-chair','Mid-century modern accent chair with button tufting and walnut legs. Available in multiple colors.','12999.00','fabric','Mustard Yellow','75x78x85 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779260079/furnishop/products/tulip-accent-chair/main.jpg',30,'2026-05-10 15:59:13.596619',3,0,'2026-05-10 15:59:13.596672','CHA-F42842','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (6,'Ergonomic Mesh Office Chair','ergonomic-mesh-office-chair','Full lumbar support mesh office chair with adjustable armrests and headrest. 8-hour comfort guarantee.','22999.00','fabric','Black','65x65x120 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258191/furnishop/products/ergonomic-mesh-office-chair/main.jpg',45,'2026-05-10 15:59:17.242536',3,1,'2026-05-10 15:59:17.242606','CHA-0DD910','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (7,'King Platform Bed Frame','king-platform-bed-frame','Solid walnut king-size platform bed with under-bed storage drawers. No box spring required.','64999.00','wood','Walnut Brown','200x180x40 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258188/furnishop/products/king-platform-bed-frame/main.jpg',12,'2026-05-10 15:59:22.484334',4,1,'2026-05-10 15:59:22.484483','BED-ADD3B2','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (8,'Upholstered Wingback Bed','upholstered-wingback-bed','Luxurious upholstered queen bed with tall wingback headboard. Soft velvet finish in rose pink.','48999.00','fabric','Dusty Rose','215x165x140 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258185/furnishop/products/upholstered-wingback-bed/main.jpg',7,'2026-05-10 15:59:26.917596',4,0,'2026-05-10 15:59:26.917672','BED-312E09','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (9,'Modular Bookshelf Unit','modular-bookshelf-unit','5-shelf modular bookshelf with adjustable shelves. Mix-and-match modules to create your perfect storage wall.','16999.00','wood','Oak White','90x35x180 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258181/furnishop/products/modular-bookshelf-unit/main.jpg',25,'2026-05-10 15:59:29.726728',5,0,'2026-05-10 15:59:29.726808','STO-40FE61','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (10,'3-Door Wardrobe','3-door-wardrobe','Sliding door wardrobe with mirror panel, hanging rods, and 4 internal shelves.','34999.00','wood','Matte White','180x60x210 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258178/furnishop/products/3-door-wardrobe/main.jpg',9,'2026-05-10 15:59:33.410762',5,0,'2026-05-10 15:59:33.410856','STO-6B755C','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (11,'Solid Oak Writing Desk','solid-oak-writing-desk','Minimalist solid oak writing desk with integrated cable management and a hidden drawer.','28999.00','wood','Natural Oak','140x70x75 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258172/furnishop/products/solid-oak-writing-desk/main.jpg',18,'2026-05-10 15:59:38.944374',6,0,'2026-05-10 15:59:38.944452','DES-D32D00','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (12,'Height Adjustable Standing Desk','height-adjustable-standing-desk','Electric sit-stand desk with memory presets. Dual motor system, whisper-quiet operation.','42999.00','metal','White Frame','160x80x72-120 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258164/furnishop/products/height-adjustable-standing-desk/main.jpg',13,'2026-05-10 15:59:43.704915',6,1,'2026-05-10 15:59:43.704987','DES-67F190','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (13,'6-Seater Teak Dining Set','6-seater-teak-dining-set','Complete 6-seater dining set in solid teak with padded chairs. Includes table and 6 chairs.','84999.00','wood','Teak Brown','Table 180x90x75 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258159/furnishop/products/6-seater-teak-dining-set/main.jpg',4,'2026-05-10 15:59:48.612611',7,1,'2026-05-10 15:59:48.612773','DIN-F44E83','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (14,'Compact 4-Seater Dining Set','compact-4-seater-dining-set','Space-saving 4-seater dining set perfect for apartments. Fold-away chairs for extra space.','36999.00','wood','Beech Natural','Table 120x70x75 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258155/furnishop/products/compact-4-seater-dining-set/main.jpg',13,'2026-05-10 15:59:50.934483',7,0,'2026-05-10 15:59:50.934551','DIN-7651BC','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (15,'Teak Garden Bench','teak-garden-bench','Weather-resistant teak garden bench. Treated with teak oil for outdoor durability.','14999.00','wood','Teak','150x55x80 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258152/furnishop/products/teak-garden-bench/main.jpg',26,'2026-05-10 15:59:53.725913',8,0,'2026-05-10 15:59:53.726051','OUT-489666','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (16,'Rattan Outdoor Lounge Set','rattan-outdoor-lounge-set','4-piece outdoor rattan lounge set with weather-resistant cushions. Includes 2 chairs, sofa, and table.','52999.00','rattan','Natural Rattan','Sofa 180x80x70 cm','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258148/furnishop/products/rattan-outdoor-lounge-set/main.jpg',2,'2026-05-10 15:59:55.110788',8,0,'2026-05-10 15:59:55.110959','OUT-441F37','active','',NULL,7,'[]','',0,'','','','4.00',1,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (17,'Samir','samir','Hello','24000.00','wood','yellow','288*288*288','https://res.cloudinary.com/de5dq6nbu/image/upload/v1779258142/furnishop/products/samir/main.jpg',0,'2026-05-10 17:08:08.746580',4,0,'2026-05-13 13:04:57.452388','BED-E908DB','active','furnotech',NULL,7,'[]','6767',0,'','','','3.00',1,7878,0,1,'hjjhjh','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (18,'Test Product XYZ','test-product-xyz','This is a test product description updated once more','26000.00','wood','Brown','100x100x100 cm','',3,'2026-05-11 08:32:24.947496',4,0,'2026-05-12 08:38:25.946827','BED-A5377A','active','FurnoTech','2026-05-12 08:38:25.943970',7,'[]','',1,'','','','0.00',0,5000,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (19,'Test Shell','test-shell','','1000.00','','','','',0,'2026-05-12 08:39:44.595103',4,0,'2026-05-12 09:26:09.183717','BED-160DEF','active','','2026-05-12 09:26:09.183486',7,'[]','',1,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (20,'Dynamic Test Chair v2','dynamic-test-chair','Dynamic Test Chair description.','5999.00','wood','Brown','100x100x100 cm','',10,'2026-05-12 08:46:54.340614',4,0,'2026-05-12 08:48:18.495641','BED-7A1743','active','','2026-05-12 08:48:18.494552',7,'[]','9403',1,'','','','0.00',0,0,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (23,'Harsh','harsh','Built with premium sarcasm-resistant technology
Supports gaming, sleeping, and overthinking simultaneously
AI-powered excuses generator included
Water resistant but not emotionally resistant
24/7 snack compatibility
Limited edition model: Harsh v2.0','99999.00','rattan','milk mm','56*56*56','https://res.cloudinary.com/de5dq6nbu/image/upload/v1/furnishop/products/harsh/111_hl0bgi',0,'2026-05-23 17:11:26.553407',9,1,'2026-05-24 04:06:15.935233','TES-03A88F','active','Harsh ods',NULL,365,'["Unlimited Talking Technology", "Premium Friendship Edition", "Meme & Reel Optimized", "Emotionally Unstable but Durable"]','9403',0,'','','','4.00',1,90,0,1,'“Ergonomic best-friend edition with unlimited talking capacity and zero battery backup.”','[{"title": "Premium Friendship Edition", "body": "\\u201cLimited stock worldwide. Crafted with sarcasm-resistant material and powered by pure chaotic energy.\\u201d", "image_url": "https://imgs.search.brave.com/BO-7NSYxwM9_zl6ri4pDsokpClE1PwZSI2jttmunZ7Y/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9tLm1l/ZGlhLWFtYXpvbi5j/b20vaW1hZ2VzL0kv/NjFzTFJYVXZla0wu/anBn", "image_alignment": "right", "order": 0}]','[]','https://www.youtube.com/watch?v=QNJL6nfu__Q&list=RDQNJL6nfu__Q&start_radio=1',1,1,'Nothing ..',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (24,'Keyword Test Product','keyword-test-product','Test','100.00','wood','brown','10x10x10',NULL,0,'2026-05-24 03:28:04.163489',1,0,'2026-05-24 03:28:04.163535','SOF-643E08','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (25,'Multipart Keyword Test','multipart-keyword-test','test','200.00','wood','red','20x20x20',NULL,0,'2026-05-24 03:28:24.363665',1,0,'2026-05-24 03:28:24.363706','SOF-00A115','active','',NULL,7,'[]','',0,'','','','0.00',0,NULL,0,1,'','[]','[]','',1,0,'',7);
INSERT INTO `products` (`id`,`name`,`slug`,`description`,`price`,`material`,`color`,`dimensions`,`image_url`,`stock`,`created_at`,`category_id`,`is_featured`,`updated_at`,`sku`,`status`,`brand`,`deleted_at`,`delivery_estimate_days`,`highlights`,`hsn_code`,`is_deleted`,`meta_description`,`meta_title`,`og_image_url`,`rating_avg`,`rating_count`,`weight_grams`,`dealer_only`,`min_order_quantity`,`short_description`,`feature_blocks`,`perks`,`youtube_url`,`warranty_years`,`installation_required`,`care_instructions`,`return_policy_days`) VALUES (26,'Varun','varun','sdcsdcdcvsfvsfvsf','54123.00','wood','white','25*25*25','https://unsplash.com/photos/woman-working-on-laptop-on-bed-with-snacks-and-books-71ig274jGpw',3,'2026-05-25 16:31:29.048345',4,0,'2026-05-25 16:31:29.048385','BED-7F32B1','active','furno',NULL,7,'[]','9403',0,'','','','0.00',0,52,0,1,'sdfs','[]','[]','',1,0,'',7);

DROP TABLE IF EXISTS `products_tags`;
CREATE TABLE `products_tags` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `product_id` bigint(20) NOT NULL,
  `tag_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `products_tags_product_id_tag_id_89ad1d4a_uniq` (`product_id`,`tag_id`),
  KEY `products_tags_tag_id_48f72775_fk` (`tag_id`),
  CONSTRAINT `products_tags_product_id_44c8dcae_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `products_tags_tag_id_48f72775_fk` FOREIGN KEY (`tag_id`) REFERENCES `product_tags` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `products_tags` (`id`,`product_id`,`tag_id`) VALUES (5,23,5);
INSERT INTO `products_tags` (`id`,`product_id`,`tag_id`) VALUES (1,24,1);
INSERT INTO `products_tags` (`id`,`product_id`,`tag_id`) VALUES (2,24,2);
INSERT INTO `products_tags` (`id`,`product_id`,`tag_id`) VALUES (3,25,3);
INSERT INTO `products_tags` (`id`,`product_id`,`tag_id`) VALUES (4,25,4);
INSERT INTO `products_tags` (`id`,`product_id`,`tag_id`) VALUES (6,26,1);

DROP TABLE IF EXISTS `refunds`;
CREATE TABLE `refunds` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `amount` decimal(10,2) NOT NULL,
  `gateway` varchar(10) NOT NULL,
  `gateway_refund_id` varchar(100) NOT NULL,
  `status` varchar(10) NOT NULL,
  `note` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `order_id` bigint(20) NOT NULL,
  `return_request_id` bigint(20) DEFAULT NULL,
  `gateway_payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`gateway_payload`)),
  PRIMARY KEY (`id`),
  KEY `refunds_order_id_33f103bc_fk_orders_id` (`order_id`),
  KEY `refunds_return_request_id_d60c6f4f_fk_order_returns_id` (`return_request_id`),
  KEY `refunds_status_c2154b17` (`status`),
  CONSTRAINT `refunds_order_id_33f103bc_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `refunds_return_request_id_d60c6f4f_fk_order_returns_id` FOREIGN KEY (`return_request_id`) REFERENCES `order_returns` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `review_votes`;
CREATE TABLE `review_votes` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `value` smallint(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `review_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `one_vote_per_user_per_review` (`review_id`,`user_id`),
  KEY `review_votes_user_id_e34a9581_fk_users_id` (`user_id`),
  CONSTRAINT `review_votes_review_id_8b42cc78_fk_reviews_id` FOREIGN KEY (`review_id`) REFERENCES `reviews` (`id`),
  CONSTRAINT `review_votes_user_id_e34a9581_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `reviews`;
CREATE TABLE `reviews` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `rating` smallint(5) unsigned NOT NULL CHECK (`rating` >= 0),
  `title` varchar(120) NOT NULL,
  `body` longtext NOT NULL,
  `verified_purchase` tinyint(1) NOT NULL,
  `status` varchar(10) NOT NULL,
  `helpful_count` int(10) unsigned NOT NULL CHECK (`helpful_count` >= 0),
  `moderated_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `moderator_id` bigint(20) DEFAULT NULL,
  `order_item_id` bigint(20) DEFAULT NULL,
  `product_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `one_review_per_user_per_product` (`product_id`,`user_id`),
  KEY `reviews_product_cae62c_idx` (`product_id`,`status`,`created_at`),
  KEY `reviews_moderator_id_c5f84a71_fk_users_id` (`moderator_id`),
  KEY `reviews_order_item_id_78ca69ec_fk_order_items_id` (`order_item_id`),
  KEY `reviews_user_id_c23b0903_fk_users_id` (`user_id`),
  KEY `reviews_verified_purchase_ba1576f8` (`verified_purchase`),
  KEY `reviews_status_7a01a82a` (`status`),
  KEY `reviews_created_at_bac0b964` (`created_at`),
  CONSTRAINT `reviews_moderator_id_c5f84a71_fk_users_id` FOREIGN KEY (`moderator_id`) REFERENCES `users` (`id`),
  CONSTRAINT `reviews_order_item_id_78ca69ec_fk_order_items_id` FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`),
  CONSTRAINT `reviews_product_id_d4b78cfe_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `reviews_user_id_c23b0903_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `reviews` (`id`,`rating`,`title`,`body`,`verified_purchase`,`status`,`helpful_count`,`moderated_at`,`created_at`,`updated_at`,`moderator_id`,`order_item_id`,`product_id`,`user_id`) VALUES (2,4,'hello','how are you',0,'approved',0,'2026-05-11 17:51:51.404150','2026-05-11 17:51:33.331826','2026-05-11 17:51:51.408099',6,NULL,16,7);
INSERT INTO `reviews` (`id`,`rating`,`title`,`body`,`verified_purchase`,`status`,`helpful_count`,`moderated_at`,`created_at`,`updated_at`,`moderator_id`,`order_item_id`,`product_id`,`user_id`) VALUES (3,3,'fssdsd','wfsffsdfsdfs',1,'approved',0,'2026-05-23 16:47:37.400129','2026-05-14 10:30:09.020552','2026-05-23 16:47:37.400287',6,31,17,7);
INSERT INTO `reviews` (`id`,`rating`,`title`,`body`,`verified_purchase`,`status`,`helpful_count`,`moderated_at`,`created_at`,`updated_at`,`moderator_id`,`order_item_id`,`product_id`,`user_id`) VALUES (4,4,'xfgxfgxf','sfvcfvdfdf',0,'approved',0,NULL,'2026-05-25 16:24:55.054856','2026-05-25 16:24:55.054888',NULL,NULL,23,21);

DROP TABLE IF EXISTS `shipping_zones`;
CREATE TABLE `shipping_zones` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(80) NOT NULL,
  `pincode_prefix` varchar(6) NOT NULL,
  `base_fee` decimal(8,2) NOT NULL,
  `per_kg_fee` decimal(8,2) NOT NULL,
  `free_shipping_threshold` decimal(10,2) NOT NULL,
  `etd_days_min` smallint(5) unsigned NOT NULL CHECK (`etd_days_min` >= 0),
  `etd_days_max` smallint(5) unsigned NOT NULL CHECK (`etd_days_max` >= 0),
  `cod_available` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `shipping_zones_pincode_prefix_b85c073c` (`pincode_prefix`),
  KEY `shipping_zones_is_active_aa74d13a` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `shipping_zones` (`id`,`name`,`pincode_prefix`,`base_fee`,`per_kg_fee`,`free_shipping_threshold`,`etd_days_min`,`etd_days_max`,`cod_available`,`is_active`,`created_at`,`updated_at`) VALUES (1,'Delhi NCR','11','149.00','25.00','5000.00',2,4,1,1,'2026-05-19 08:26:51.193964','2026-05-19 08:26:51.193990');
INSERT INTO `shipping_zones` (`id`,`name`,`pincode_prefix`,`base_fee`,`per_kg_fee`,`free_shipping_threshold`,`etd_days_min`,`etd_days_max`,`cod_available`,`is_active`,`created_at`,`updated_at`) VALUES (2,'Mumbai','40','199.00','30.00','6000.00',3,5,1,1,'2026-05-19 08:26:51.637750','2026-05-19 08:26:51.637777');
INSERT INTO `shipping_zones` (`id`,`name`,`pincode_prefix`,`base_fee`,`per_kg_fee`,`free_shipping_threshold`,`etd_days_min`,`etd_days_max`,`cod_available`,`is_active`,`created_at`,`updated_at`) VALUES (3,'Bengaluru','56','189.00','28.00','5500.00',3,6,1,1,'2026-05-19 08:26:52.108161','2026-05-19 08:26:52.108246');
INSERT INTO `shipping_zones` (`id`,`name`,`pincode_prefix`,`base_fee`,`per_kg_fee`,`free_shipping_threshold`,`etd_days_min`,`etd_days_max`,`cod_available`,`is_active`,`created_at`,`updated_at`) VALUES (4,'Chennai','60','189.00','28.00','5500.00',3,6,1,1,'2026-05-19 08:26:52.696053','2026-05-19 08:26:52.696078');
INSERT INTO `shipping_zones` (`id`,`name`,`pincode_prefix`,`base_fee`,`per_kg_fee`,`free_shipping_threshold`,`etd_days_min`,`etd_days_max`,`cod_available`,`is_active`,`created_at`,`updated_at`) VALUES (5,'Hyderabad','50','189.00','28.00','5500.00',3,6,1,1,'2026-05-19 08:26:53.184186','2026-05-19 08:26:53.184216');
INSERT INTO `shipping_zones` (`id`,`name`,`pincode_prefix`,`base_fee`,`per_kg_fee`,`free_shipping_threshold`,`etd_days_min`,`etd_days_max`,`cod_available`,`is_active`,`created_at`,`updated_at`) VALUES (6,'Kolkata','70','209.00','32.00','6500.00',4,7,1,1,'2026-05-19 08:26:53.710066','2026-05-19 08:26:53.710109');

DROP TABLE IF EXISTS `sms_campaigns`;
CREATE TABLE `sms_campaigns` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `uid` char(32) NOT NULL,
  `name` varchar(200) NOT NULL,
  `message` longtext NOT NULL,
  `audience` varchar(20) NOT NULL,
  `audience_tag` varchar(80) NOT NULL,
  `status` varchar(10) NOT NULL,
  `total_count` int(10) unsigned NOT NULL CHECK (`total_count` >= 0),
  `sent_count` int(10) unsigned NOT NULL CHECK (`sent_count` >= 0),
  `failed_count` int(10) unsigned NOT NULL CHECK (`failed_count` >= 0),
  `error_log` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `sent_at` datetime(6) DEFAULT NULL,
  `created_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uid` (`uid`),
  KEY `sms_campaigns_created_by_id_e53121dc_fk_users_id` (`created_by_id`),
  KEY `sms_campaigns_status_45f8eb43` (`status`),
  CONSTRAINT `sms_campaigns_created_by_id_e53121dc_fk_users_id` FOREIGN KEY (`created_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `sms_contacts`;
CREATE TABLE `sms_contacts` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) NOT NULL,
  `name` varchar(120) NOT NULL,
  `tag` varchar(80) NOT NULL,
  `source` varchar(30) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `phone` (`phone`),
  KEY `sms_contacts_tag_4d23e10d` (`tag`),
  KEY `sms_contacts_is_active_ec210e02` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `sms_contacts` (`id`,`phone`,`name`,`tag`,`source`,`is_active`,`created_at`) VALUES (4,'+919876543210','Rahul Chawla','wishlist_10000','structured',1,'2026-05-23 09:21:56.328850');

DROP TABLE IF EXISTS `sms_deliveries`;
CREATE TABLE `sms_deliveries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `phone` varchar(20) NOT NULL,
  `name` varchar(120) NOT NULL,
  `status` varchar(10) NOT NULL,
  `provider_response` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`provider_response`)),
  `sent_at` datetime(6) DEFAULT NULL,
  `campaign_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sms_deliveries_phone_0b99a4d9` (`phone`),
  KEY `sms_deliveries_status_545c1b6e` (`status`),
  KEY `sms_deliver_campaig_1ac15b_idx` (`campaign_id`,`status`),
  CONSTRAINT `sms_deliveries_campaign_id_b4457cee_fk_sms_campaigns_id` FOREIGN KEY (`campaign_id`) REFERENCES `sms_campaigns` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `social_auth_association`;
CREATE TABLE `social_auth_association` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `server_url` varchar(255) NOT NULL,
  `handle` varchar(255) NOT NULL,
  `secret` varchar(255) NOT NULL,
  `issued` int(11) NOT NULL,
  `lifetime` int(11) NOT NULL,
  `assoc_type` varchar(64) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_association_server_url_handle_078befa2_uniq` (`server_url`,`handle`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `social_auth_code`;
CREATE TABLE `social_auth_code` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `code` varchar(32) NOT NULL,
  `verified` tinyint(1) NOT NULL,
  `timestamp` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_code_email_code_801b2d02_uniq` (`email`,`code`),
  KEY `social_auth_code_code_a2393167` (`code`),
  KEY `social_auth_code_timestamp_176b341f` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `social_auth_nonce`;
CREATE TABLE `social_auth_nonce` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `server_url` varchar(255) NOT NULL,
  `timestamp` int(11) NOT NULL,
  `salt` varchar(65) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_nonce_server_url_timestamp_salt_f6284463_uniq` (`server_url`,`timestamp`,`salt`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `social_auth_partial`;
CREATE TABLE `social_auth_partial` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` varchar(32) NOT NULL,
  `next_step` smallint(5) unsigned NOT NULL CHECK (`next_step` >= 0),
  `backend` varchar(32) NOT NULL,
  `timestamp` datetime(6) NOT NULL,
  `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`data`)),
  PRIMARY KEY (`id`),
  KEY `social_auth_partial_token_3017fea3` (`token`),
  KEY `social_auth_partial_timestamp_50f2119f` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `social_auth_usersocialauth`;
CREATE TABLE `social_auth_usersocialauth` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `provider` varchar(32) NOT NULL,
  `uid` varchar(255) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `created` datetime(6) NOT NULL,
  `modified` datetime(6) NOT NULL,
  `extra_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`extra_data`)),
  PRIMARY KEY (`id`),
  UNIQUE KEY `social_auth_usersocialauth_provider_uid_e6b5e668_uniq` (`provider`,`uid`),
  KEY `social_auth_usersocialauth_user_id_17d28448_fk_users_id` (`user_id`),
  KEY `social_auth_usersocialauth_uid_796e51dc` (`uid`),
  CONSTRAINT `social_auth_usersocialauth_user_id_17d28448_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `user_social_auth_uid_required` CHECK (`uid` <> '')
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `stock_levels`;
CREATE TABLE `stock_levels` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `quantity` int(11) NOT NULL,
  `low_threshold` int(10) unsigned NOT NULL CHECK (`low_threshold` >= 0),
  `updated_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  `warehouse_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `stock_levels_product_id_variant_id_warehouse_id_096447e9_uniq` (`product_id`,`variant_id`,`warehouse_id`),
  KEY `stock_level_warehou_588e6e_idx` (`warehouse_id`,`product_id`),
  KEY `stock_levels_variant_id_03fa3423_fk_product_variants_id` (`variant_id`),
  CONSTRAINT `stock_levels_product_id_e115bc87_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `stock_levels_variant_id_03fa3423_fk_product_variants_id` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`),
  CONSTRAINT `stock_levels_warehouse_id_456e948b_fk_warehouses_id` FOREIGN KEY (`warehouse_id`) REFERENCES `warehouses` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (1,10,3,'2026-05-11 04:48:12.202587',17,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (2,10,3,'2026-05-11 04:48:12.289177',16,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (3,10,3,'2026-05-11 04:48:12.398599',15,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (4,10,3,'2026-05-11 04:48:12.489111',14,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (5,10,3,'2026-05-11 04:48:12.588728',13,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (6,10,3,'2026-05-11 04:48:12.687060',12,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (7,10,3,'2026-05-11 04:48:12.788071',11,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (8,15,3,'2026-05-13 13:33:24.019332',10,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (9,10,3,'2026-05-11 04:48:12.968610',9,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (10,10,3,'2026-05-11 04:48:13.058199',8,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (11,10,3,'2026-05-11 04:48:13.148190',7,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (12,10,3,'2026-05-11 04:48:13.239160',6,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (13,10,3,'2026-05-11 04:48:13.335451',5,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (14,10,3,'2026-05-11 04:48:13.433007',4,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (15,10,3,'2026-05-11 04:48:13.528846',3,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (16,10,3,'2026-05-11 04:48:13.618081',2,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (17,10,3,'2026-05-11 04:48:13.714999',1,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (18,3,5,'2026-05-12 07:03:20.027724',18,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (19,10,5,'2026-05-19 08:26:46.073117',20,NULL,1);
INSERT INTO `stock_levels` (`id`,`quantity`,`low_threshold`,`updated_at`,`product_id`,`variant_id`,`warehouse_id`) VALUES (20,0,5,'2026-05-19 08:26:46.601896',19,NULL,1);

DROP TABLE IF EXISTS `stock_movements`;
CREATE TABLE `stock_movements` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `delta` int(11) NOT NULL,
  `reason` varchar(20) NOT NULL,
  `reference` varchar(64) NOT NULL,
  `note` longtext NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `actor_id` bigint(20) DEFAULT NULL,
  `stock_level_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `stock_movements_actor_id_d66756a5_fk_users_id` (`actor_id`),
  KEY `stock_movements_stock_level_id_adcde1de_fk_stock_levels_id` (`stock_level_id`),
  KEY `stock_movements_created_at_cd82239e` (`created_at`),
  CONSTRAINT `stock_movements_actor_id_d66756a5_fk_users_id` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `stock_movements_stock_level_id_adcde1de_fk_stock_levels_id` FOREIGN KEY (`stock_level_id`) REFERENCES `stock_levels` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `stock_movements` (`id`,`delta`,`reason`,`reference`,`note`,`created_at`,`actor_id`,`stock_level_id`) VALUES (1,3,'inbound','','Seeded from existing Product.stock','2026-05-12 07:03:20.115062',NULL,18);
INSERT INTO `stock_movements` (`id`,`delta`,`reason`,`reference`,`note`,`created_at`,`actor_id`,`stock_level_id`) VALUES (2,5,'inbound','','flow test','2026-05-13 13:33:24.206738',6,8);
INSERT INTO `stock_movements` (`id`,`delta`,`reason`,`reference`,`note`,`created_at`,`actor_id`,`stock_level_id`) VALUES (3,10,'inbound','','Seeded from existing Product.stock','2026-05-19 08:26:46.160790',NULL,19);

DROP TABLE IF EXISTS `store_settings`;
CREATE TABLE `store_settings` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `gst_percent` decimal(5,2) NOT NULL,
  `free_shipping_threshold` decimal(10,2) NOT NULL,
  `standard_shipping_fee` decimal(10,2) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `updated_by_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `store_settings_updated_by_id_a04eb77a_fk_users_id` (`updated_by_id`),
  CONSTRAINT `store_settings_updated_by_id_a04eb77a_fk_users_id` FOREIGN KEY (`updated_by_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `store_settings` (`id`,`gst_percent`,`free_shipping_threshold`,`standard_shipping_fee`,`updated_at`,`updated_by_id`) VALUES (1,'18.00','2999.00','499.00','2026-05-13 14:01:38.968780',6);

DROP TABLE IF EXISTS `subscribers`;
CREATE TABLE `subscribers` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `welcomed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `subscribers` (`id`,`email`,`is_active`,`created_at`,`welcomed_at`) VALUES (1,'varunkumart.cse22@sbjit.edu.in',1,'2026-05-22 13:56:30.214915','2026-05-22 13:56:34.055150');

DROP TABLE IF EXISTS `support_faq_entries`;
CREATE TABLE `support_faq_entries` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `topic` varchar(80) NOT NULL,
  `question` varchar(240) NOT NULL,
  `answer` longtext NOT NULL,
  `triggers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`triggers`)),
  `follow_up_prompts` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`follow_up_prompts`)),
  `sort_order` int(10) unsigned NOT NULL CHECK (`sort_order` >= 0),
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `support_faq_entries_topic_cb0834b5` (`topic`),
  KEY `support_faq_entries_sort_order_a9147fb4` (`sort_order`),
  KEY `support_faq_entries_is_active_2a3c00e5` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (1,'Package & delivery','My package hasn't arrived yet','Sorry about that. Could you share:
  1. Your order ID (looks like ORD-XXXXXXXX)
  2. Your registered phone or email
  3. When you placed the order

You can check live status under My Orders -> Track. Most orders deliver within 3-7 business days. If it's been longer, I'll escalate this to our team.','["package", "parcel", "didn't arrive", "not arrived", "not received", "where is my order", "tracking", "delayed"]','["Track my order", "Order delivered to wrong address", "Contact support"]',10,1,'2026-05-23 09:33:28.925805','2026-05-23 13:11:14.798421');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (2,'Package & delivery','Track my order','Open My Orders -> click the order -> the tracking number and carrier appear at the top of the page. If tracking shows no movement for 48 hours, reply here with your order ID and I'll raise a ticket.','["track", "tracking number", "where is", "carrier"]','["My package hasn't arrived yet", "Contact support"]',11,1,'2026-05-23 09:33:29.648531','2026-05-23 09:33:29.648582');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (3,'Package & delivery','Order delivered to wrong address','Please raise a ticket with the correct address and your order ID. Our team will arrange pickup + redelivery within 24-48 hours. Refunds available if the wrong-address delivery was our fault.','["wrong address", "wrong location", "address change"]','["Contact support"]',12,1,'2026-05-23 09:33:30.338324','2026-05-23 09:33:30.338375');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (4,'Payment & refund','Payment failed but money was deducted','Failed payments auto-refund within 5-7 business days. The bank may show it as 'pending' until then. If 7 days have passed and the amount hasn't returned, share your order ID + transaction reference and I'll escalate.','["payment failed", "money deducted", "payment not received", "amount debited", "paid but"]','["Refund status", "Contact support"]',20,1,'2026-05-23 09:33:31.153029','2026-05-23 09:33:31.153089');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (5,'Payment & refund','Refund status','Refunds for cancelled / returned orders process within 3-5 business days after we receive the item back. UPI / wallet refunds are usually instant; card / netbanking can take up to 7 days. Reply with your order ID for the current status.','["refund", "money back", "reverse payment"]','["Cancel my order", "Contact support"]',21,1,'2026-05-23 09:33:31.855692','2026-05-23 09:33:31.855756');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (6,'Returns & cancellations','Return an item','You have 30 days from delivery to return unused items. Open My Orders -> select the order -> click 'Return' -> pick the reason -> we'll arrange free pickup within 2 business days.','["return", "send back", "change my mind", "not happy"]','["Refund status", "Cancel my order"]',30,1,'2026-05-23 09:33:32.717396','2026-05-23 09:33:32.717458');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (7,'Returns & cancellations','Cancel my order','Orders can be cancelled free of charge as long as they haven't shipped yet (usually a 60-minute window after placing). Open My Orders -> click the order -> Cancel. After shipping, please use the Return option once it arrives.','["cancel", "cancellation"]','["Return an item", "Refund status"]',31,1,'2026-05-23 09:33:33.483783','2026-05-23 09:33:33.483841');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (8,'Account','I can't log in / forgot password','Click 'Forgot password?' on the login screen, enter your email, and we'll send a reset link instantly. Check your spam folder if you don't see it in 2 minutes.','["login", "log in", "sign in", "password", "forgot", "can't access", "locked out"]','["Update my email", "Contact support"]',40,1,'2026-05-23 09:33:34.163379','2026-05-23 09:33:34.163417');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (9,'Account','Update my email or phone','Go to My Account -> Profile -> Edit. Email changes require re-verification (we'll email a 6-digit code). For phone, just update and save.','["change email", "update email", "change phone", "update phone", "edit profile"]','[]',41,1,'2026-05-23 09:33:34.845333','2026-05-23 09:33:34.845407');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (10,'Product & warranty','Warranty claim','All FurniShop products come with a 1-year manufacturer warranty against defects. Raise a ticket with: order ID, item, photo of the defect, and a short description. Our team responds in 24h.','["warranty", "defect", "broken", "damaged", "not working", "manufacturing"]','["Contact support"]',50,1,'2026-05-23 09:33:35.548168','2026-05-23 09:33:35.548203');
INSERT INTO `support_faq_entries` (`id`,`topic`,`question`,`answer`,`triggers`,`follow_up_prompts`,`sort_order`,`is_active`,`created_at`,`updated_at`) VALUES (11,'accounts','account not working','cvsffsdffsdfdf','[]','[]',100,1,'2026-05-25 17:29:30.799376','2026-05-25 17:29:30.799405');

DROP TABLE IF EXISTS `support_ticket_messages`;
CREATE TABLE `support_ticket_messages` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `body` longtext NOT NULL,
  `is_internal_note` tinyint(1) NOT NULL,
  `attachment_url` varchar(500) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `sender_id` bigint(20) DEFAULT NULL,
  `ticket_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `support_ticket_messages_ticket_id_e46e48c2_fk_support_tickets_id` (`ticket_id`),
  KEY `support_ticket_messages_sender_id_eeb9cba3_fk_users_id` (`sender_id`),
  CONSTRAINT `support_ticket_messages_sender_id_eeb9cba3_fk_users_id` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`),
  CONSTRAINT `support_ticket_messages_ticket_id_e46e48c2_fk_support_tickets_id` FOREIGN KEY (`ticket_id`) REFERENCES `support_tickets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (1,'dsdffds',0,'','2026-05-11 05:07:57.804089',8,1);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (2,'My order was supposed to ship to Nagpur but I see the tracking showing Mumbai. Please help.',0,'','2026-05-11 05:12:25.091277',8,2);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (3,'why not',0,'','2026-05-11 05:13:22.257156',6,1);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (4,'okay clos it',0,'','2026-05-11 05:14:11.829125',8,1);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (5,'My order arrived but one item is missing.',0,'','2026-05-11 09:07:04.251321',8,3);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (6,'We are looking into this.',0,'','2026-05-11 09:09:58.418282',6,3);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (7,'Test Message',0,'','2026-05-11 13:08:39.753525',NULL,4);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (8,'LL',0,'','2026-05-18 06:34:52.853357',8,5);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (9,'OK SOLVED',0,'','2026-05-18 06:35:49.269424',6,5);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (10,'Product doesnt received .',0,'','2026-05-18 08:28:49.695409',15,6);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (11,'Thank you .',0,'','2026-05-18 08:30:44.572069',6,6);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (12,'What do you think .',0,'','2026-05-23 13:22:59.417035',19,7);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (13,'Nothing .',0,'','2026-05-23 13:23:53.692414',6,7);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (14,'From the chatbot escalation flow.',0,'','2026-05-26 15:07:33.899430',7,8);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (15,'Body OK',0,'','2026-05-26 17:07:40.876685',7,9);
INSERT INTO `support_ticket_messages` (`id`,`body`,`is_internal_note`,`attachment_url`,`created_at`,`sender_id`,`ticket_id`) VALUES (16,'ghjk',0,'','2026-05-29 06:42:46.180616',7,10);

DROP TABLE IF EXISTS `support_tickets`;
CREATE TABLE `support_tickets` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `ticket_number` varchar(20) NOT NULL,
  `subject` varchar(200) NOT NULL,
  `category` varchar(12) NOT NULL,
  `priority` varchar(8) NOT NULL,
  `status` varchar(20) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `resolved_at` datetime(6) DEFAULT NULL,
  `closed_at` datetime(6) DEFAULT NULL,
  `assigned_to_id` bigint(20) DEFAULT NULL,
  `related_order_id` bigint(20) DEFAULT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `guest_email` varchar(255) DEFAULT NULL,
  `guest_name` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticket_number` (`ticket_number`),
  KEY `support_tic_user_id_057736_idx` (`user_id`,`status`),
  KEY `support_tic_priorit_21ff2f_idx` (`priority`,`status`),
  KEY `support_tickets_assigned_to_id_b3ca73d5_fk_users_id` (`assigned_to_id`),
  KEY `support_tickets_related_order_id_726cd236_fk_orders_id` (`related_order_id`),
  KEY `support_tickets_priority_175f4fdc` (`priority`),
  KEY `support_tickets_status_1b7ccc40` (`status`),
  CONSTRAINT `support_tickets_assigned_to_id_b3ca73d5_fk_users_id` FOREIGN KEY (`assigned_to_id`) REFERENCES `users` (`id`),
  CONSTRAINT `support_tickets_related_order_id_726cd236_fk_orders_id` FOREIGN KEY (`related_order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `support_tickets_user_id_2e4c3168_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (1,'TKT-2026-00001','hello samir','order','normal','closed','2026-05-11 05:07:57.698359','2026-05-11 05:07:57.698398',NULL,'2026-05-11 05:15:03.857106',6,NULL,8,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (2,'TKT-2026-00002','Order ORD-098807E9 shipped to wrong city','shipping','high','closed','2026-05-11 05:12:24.999618','2026-05-11 05:12:24.999672','2026-05-11 05:23:48.682297','2026-05-11 05:23:53.913024',6,NULL,8,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (3,'TKT-2026-00003','Missing item','order','normal','awaiting_customer','2026-05-11 09:07:04.137026','2026-05-11 09:07:04.137092',NULL,NULL,NULL,NULL,8,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (4,'TKT-2026-00004','Test Subject','order','normal','closed','2026-05-11 13:08:39.651709','2026-05-11 13:08:39.651833',NULL,'2026-05-18 06:33:01.675588',6,NULL,NULL,'guest@test.com','Test Guest');
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (5,'TKT-2026-00005','PRADIP','credit','high','awaiting_customer','2026-05-18 06:34:52.669786','2026-05-18 06:34:52.669825',NULL,NULL,NULL,NULL,8,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (6,'TKT-2026-00006','Hello','product','high','closed','2026-05-18 08:28:49.508566','2026-05-18 08:28:49.508653',NULL,'2026-05-18 08:30:58.163200',6,NULL,15,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (7,'TKT-2026-00007','Is Samir a bad boy','order','high','awaiting_customer','2026-05-23 13:22:59.228767','2026-05-23 13:22:59.228816',NULL,NULL,NULL,NULL,19,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (8,'TKT-2026-00008','Test Chatbot Fix','other','normal','open','2026-05-26 15:07:33.699024','2026-05-26 15:07:33.699074',NULL,NULL,NULL,NULL,7,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (9,'TKT-2026-00009','Final smoke','other','normal','open','2026-05-26 17:07:40.681830','2026-05-26 17:07:40.681882',NULL,NULL,NULL,NULL,7,NULL,NULL);
INSERT INTO `support_tickets` (`id`,`ticket_number`,`subject`,`category`,`priority`,`status`,`created_at`,`updated_at`,`resolved_at`,`closed_at`,`assigned_to_id`,`related_order_id`,`user_id`,`guest_email`,`guest_name`) VALUES (10,'TKT-2026-00010','recfvbhub','order','normal','closed','2026-05-29 06:42:45.992573','2026-05-29 06:42:45.992613',NULL,'2026-05-29 06:56:59.559671',6,NULL,7,NULL,NULL);

DROP TABLE IF EXISTS `token_blacklist_blacklistedtoken`;
CREATE TABLE `token_blacklist_blacklistedtoken` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `blacklisted_at` datetime(6) NOT NULL,
  `token_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_id` (`token_id`),
  CONSTRAINT `token_blacklist_blacklistedtoken_token_id_3cc7fe56_fk` FOREIGN KEY (`token_id`) REFERENCES `token_blacklist_outstandingtoken` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=455 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (1,'2026-05-10 16:03:40.289245',1);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (2,'2026-05-10 16:10:32.288165',4);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (3,'2026-05-10 16:11:48.630630',5);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (4,'2026-05-10 16:17:03.735637',6);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (5,'2026-05-10 17:03:53.545409',7);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (6,'2026-05-10 17:10:15.440250',10);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (7,'2026-05-10 17:12:49.744956',11);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (8,'2026-05-10 17:15:13.659275',12);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (9,'2026-05-10 17:17:19.106930',13);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (10,'2026-05-10 17:18:25.730607',14);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (11,'2026-05-11 04:14:33.876664',15);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (12,'2026-05-11 04:15:14.710855',16);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (13,'2026-05-11 04:16:37.585488',17);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (14,'2026-05-11 04:25:47.913861',19);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (15,'2026-05-11 04:26:25.523610',20);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (16,'2026-05-11 04:40:07.990855',21);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (17,'2026-05-11 04:44:33.951608',26);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (18,'2026-05-11 04:46:12.016015',27);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (19,'2026-05-11 05:06:47.098402',30);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (20,'2026-05-11 05:09:34.363912',41);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (21,'2026-05-11 05:13:46.780378',46);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (22,'2026-05-11 05:14:45.075812',47);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (23,'2026-05-11 05:22:43.588493',48);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (24,'2026-05-11 05:23:04.555032',54);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (25,'2026-05-11 05:31:35.052849',55);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (26,'2026-05-11 05:33:03.316759',56);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (27,'2026-05-11 05:33:27.222791',57);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (28,'2026-05-11 05:34:59.595563',58);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (29,'2026-05-11 05:35:21.986203',59);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (30,'2026-05-11 07:25:07.419866',60);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (31,'2026-05-11 07:32:06.247099',62);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (32,'2026-05-11 07:35:09.427539',64);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (33,'2026-05-11 07:39:36.427481',66);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (34,'2026-05-11 07:41:16.017966',68);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (35,'2026-05-11 07:44:01.852864',69);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (36,'2026-05-11 08:15:49.503943',71);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (37,'2026-05-11 08:25:49.913019',73);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (38,'2026-05-11 08:26:31.879142',76);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (39,'2026-05-11 08:30:36.128132',78);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (40,'2026-05-11 08:48:24.697657',80);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (41,'2026-05-11 08:49:26.053915',82);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (42,'2026-05-11 08:51:22.579772',84);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (43,'2026-05-11 08:52:43.391055',86);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (44,'2026-05-11 08:55:16.668253',88);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (45,'2026-05-11 08:57:34.938649',90);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (46,'2026-05-11 08:58:20.735719',91);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (47,'2026-05-11 09:02:01.268252',93);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (48,'2026-05-11 09:04:44.960678',95);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (49,'2026-05-11 09:05:12.357644',97);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (50,'2026-05-11 09:09:33.524264',99);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (51,'2026-05-11 09:16:44.455994',101);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (52,'2026-05-11 09:22:52.202443',103);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (53,'2026-05-11 09:33:20.924154',105);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (54,'2026-05-11 09:35:54.005749',107);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (55,'2026-05-11 09:43:53.279098',109);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (57,'2026-05-11 11:47:17.282474',74);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (59,'2026-05-11 12:13:48.095601',115);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (60,'2026-05-11 12:16:39.572574',116);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (61,'2026-05-11 12:18:25.549768',117);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (63,'2026-05-11 12:19:32.107805',119);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (64,'2026-05-11 12:22:29.952991',120);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (65,'2026-05-11 12:29:28.390920',122);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (67,'2026-05-11 13:01:04.591254',125);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (69,'2026-05-11 13:01:48.510662',128);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (70,'2026-05-11 13:04:09.828349',129);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (72,'2026-05-11 13:05:32.487279',131);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (74,'2026-05-11 13:06:59.097126',134);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (76,'2026-05-11 13:07:35.364293',136);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (77,'2026-05-11 13:15:22.639327',132);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (78,'2026-05-11 14:31:33.840560',137);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (80,'2026-05-11 14:33:03.013818',139);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (81,'2026-05-11 14:34:16.352851',141);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (82,'2026-05-11 14:38:10.738238',142);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (84,'2026-05-11 14:40:22.708785',144);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (86,'2026-05-11 14:42:03.875496',146);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (87,'2026-05-11 14:44:14.086130',147);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (88,'2026-05-11 14:47:50.211854',148);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (89,'2026-05-11 16:53:17.622328',150);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (91,'2026-05-11 17:02:22.261222',152);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (93,'2026-05-11 17:03:16.912215',154);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (95,'2026-05-11 17:03:52.312517',156);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (97,'2026-05-11 17:05:20.287432',158);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (99,'2026-05-11 17:05:27.443175',160);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (101,'2026-05-11 17:19:13.652709',162);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (103,'2026-05-11 17:38:56.276502',165);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (105,'2026-05-11 17:39:16.551802',167);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (106,'2026-05-11 17:40:51.322546',168);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (108,'2026-05-11 17:41:07.146765',171);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (109,'2026-05-11 17:41:49.105224',172);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (111,'2026-05-11 17:42:46.936289',174);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (113,'2026-05-11 17:43:00.989298',176);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (114,'2026-05-11 17:43:52.517740',177);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (116,'2026-05-11 17:44:07.593013',179);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (117,'2026-05-11 17:50:11.369087',180);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (118,'2026-05-11 17:51:45.191185',181);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (120,'2026-05-11 17:52:37.960474',182);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (122,'2026-05-11 17:53:15.077583',184);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (124,'2026-05-11 17:58:12.919818',188);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (126,'2026-05-11 18:00:45.715981',190);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (128,'2026-05-11 18:04:43.639983',192);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (129,'2026-05-11 18:08:40.575324',193);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (131,'2026-05-11 18:08:47.027327',186);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (133,'2026-05-11 18:10:07.771796',195);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (134,'2026-05-11 18:14:17.722084',198);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (135,'2026-05-12 05:13:47.844861',200);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (136,'2026-05-12 06:05:31.536773',201);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (138,'2026-05-12 06:09:38.344234',203);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (140,'2026-05-12 06:10:52.844587',205);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (142,'2026-05-12 06:24:46.186053',207);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (144,'2026-05-12 06:34:03.318069',209);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (146,'2026-05-12 06:35:30.665570',211);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (148,'2026-05-12 06:35:57.435013',213);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (150,'2026-05-12 07:05:26.327019',216);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (152,'2026-05-12 07:10:30.523683',218);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (153,'2026-05-12 07:28:15.808869',219);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (154,'2026-05-12 07:29:22.434816',220);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (156,'2026-05-12 08:01:18.822575',223);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (158,'2026-05-12 08:09:05.391742',225);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (160,'2026-05-12 08:18:56.933810',227);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (162,'2026-05-12 08:19:14.985777',229);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (164,'2026-05-12 08:21:57.734005',232);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (166,'2026-05-12 08:38:23.643258',234);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (167,'2026-05-12 08:44:12.203759',235);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (169,'2026-05-12 08:49:28.646993',237);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (171,'2026-05-12 08:50:32.615973',239);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (173,'2026-05-12 08:51:25.815945',241);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (175,'2026-05-12 09:33:11.319059',244);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (177,'2026-05-12 09:34:31.371723',243);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (179,'2026-05-12 09:36:14.937933',248);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (180,'2026-05-12 09:37:36.623791',251);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (182,'2026-05-12 09:39:19.297340',253);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (184,'2026-05-12 09:40:06.414442',255);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (186,'2026-05-12 09:40:44.426082',257);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (188,'2026-05-12 09:41:02.695084',259);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (190,'2026-05-12 14:40:52.333117',262);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (192,'2026-05-12 14:44:07.605387',246);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (194,'2026-05-12 14:44:14.366587',266);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (195,'2026-05-12 14:45:23.331203',267);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (197,'2026-05-12 14:45:44.186299',269);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (198,'2026-05-12 14:48:05.511895',264);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (200,'2026-05-12 15:13:46.994002',272);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (202,'2026-05-12 15:13:50.643047',274);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (204,'2026-05-12 15:20:17.417463',276);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (206,'2026-05-12 15:27:52.211407',279);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (207,'2026-05-12 15:27:54.295044',278);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (209,'2026-05-12 15:45:23.857235',286);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (211,'2026-05-12 15:47:48.887681',288);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (213,'2026-05-12 15:52:34.095445',290);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (214,'2026-05-12 15:53:26.103294',291);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (216,'2026-05-12 15:53:59.641763',293);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (218,'2026-05-12 15:54:11.769008',296);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (219,'2026-05-12 15:59:13.612828',298);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (221,'2026-05-12 16:02:20.620334',300);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (223,'2026-05-12 16:04:32.109177',302);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (225,'2026-05-12 16:08:39.054943',304);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (227,'2026-05-12 16:13:16.117166',306);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (229,'2026-05-12 16:16:49.100055',308);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (231,'2026-05-12 16:17:11.929788',310);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (233,'2026-05-12 16:17:25.218333',312);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (235,'2026-05-12 16:19:30.175606',315);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (237,'2026-05-12 16:19:47.128442',317);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (239,'2026-05-12 16:19:56.307289',319);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (241,'2026-05-12 16:20:46.252682',321);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (243,'2026-05-12 16:20:51.554201',322);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (245,'2026-05-12 16:21:18.950528',326);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (247,'2026-05-12 16:21:31.446852',328);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (249,'2026-05-12 16:22:11.017028',331);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (251,'2026-05-12 16:22:19.128280',333);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (252,'2026-05-12 16:23:05.578707',334);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (253,'2026-05-12 16:26:45.605326',335);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (255,'2026-05-12 16:26:59.256805',337);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (257,'2026-05-12 16:27:36.910917',340);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (258,'2026-05-12 16:27:46.819746',341);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (260,'2026-05-12 16:27:59.147974',343);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (262,'2026-05-12 17:25:15.947564',345);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (264,'2026-05-12 17:25:55.624450',347);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (265,'2026-05-12 17:26:27.903716',348);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (266,'2026-05-13 06:54:48.257554',349);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (268,'2026-05-13 06:58:07.679515',351);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (269,'2026-05-13 07:06:18.718470',352);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (270,'2026-05-13 07:10:48.510094',353);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (272,'2026-05-13 07:12:32.042933',355);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (274,'2026-05-13 07:14:29.882643',358);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (276,'2026-05-13 07:23:45.324847',360);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (278,'2026-05-13 07:59:26.051213',362);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (279,'2026-05-13 07:59:49.613471',363);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (280,'2026-05-13 08:13:38.599266',367);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (281,'2026-05-13 08:14:55.568504',368);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (282,'2026-05-13 08:15:47.111673',369);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (283,'2026-05-13 12:20:00.477720',374);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (284,'2026-05-13 12:20:15.386560',375);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (285,'2026-05-13 12:22:22.893363',376);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (286,'2026-05-13 12:22:31.791527',377);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (287,'2026-05-13 12:22:39.793542',378);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (288,'2026-05-13 12:23:02.721893',379);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (289,'2026-05-13 12:39:02.701732',385);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (290,'2026-05-13 12:39:30.338705',386);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (291,'2026-05-13 12:42:05.722871',387);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (292,'2026-05-13 12:42:57.378710',388);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (293,'2026-05-13 13:04:17.197849',389);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (294,'2026-05-13 13:05:06.940477',390);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (295,'2026-05-13 13:05:30.916146',391);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (296,'2026-05-13 13:07:47.266106',392);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (297,'2026-05-13 13:51:42.667086',401);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (298,'2026-05-13 13:52:33.300589',402);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (299,'2026-05-13 13:53:04.103534',403);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (300,'2026-05-13 13:58:44.999588',404);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (301,'2026-05-13 14:01:42.639123',405);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (302,'2026-05-13 14:25:47.621802',406);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (303,'2026-05-13 14:27:16.850358',407);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (304,'2026-05-13 14:28:33.868725',408);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (305,'2026-05-13 15:01:11.025001',409);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (306,'2026-05-13 15:02:39.067198',410);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (307,'2026-05-13 15:07:17.152868',411);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (308,'2026-05-13 15:10:50.297102',412);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (309,'2026-05-13 15:13:09.279300',413);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (310,'2026-05-13 15:35:45.513655',414);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (311,'2026-05-13 15:37:45.322418',415);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (312,'2026-05-13 15:38:01.071223',416);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (313,'2026-05-13 15:38:21.368854',417);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (314,'2026-05-13 15:38:55.257115',418);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (315,'2026-05-13 15:39:25.316924',419);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (316,'2026-05-13 17:43:38.291151',420);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (317,'2026-05-13 17:43:54.012507',421);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (318,'2026-05-13 17:44:12.267337',422);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (319,'2026-05-13 17:45:27.454483',423);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (320,'2026-05-13 17:45:46.555277',424);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (321,'2026-05-13 17:45:57.491816',425);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (322,'2026-05-13 17:46:07.054265',426);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (323,'2026-05-14 10:34:29.874136',428);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (324,'2026-05-14 10:45:28.977941',429);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (326,'2026-05-14 10:46:49.309681',430);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (327,'2026-05-14 10:48:02.305924',431);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (328,'2026-05-14 10:57:03.247665',432);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (329,'2026-05-14 10:59:47.463595',433);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (330,'2026-05-14 11:00:17.285740',434);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (331,'2026-05-14 11:07:35.937577',435);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (332,'2026-05-14 11:28:55.568702',436);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (333,'2026-05-14 11:36:30.431214',439);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (334,'2026-05-14 11:37:21.490531',437);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (335,'2026-05-14 11:38:04.069625',440);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (336,'2026-05-14 11:39:46.656560',441);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (337,'2026-05-14 11:41:42.187078',442);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (338,'2026-05-14 11:44:11.183482',444);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (339,'2026-05-14 11:45:11.341301',445);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (340,'2026-05-14 11:48:40.500956',443);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (341,'2026-05-14 11:48:49.389452',446);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (342,'2026-05-14 16:14:07.287370',448);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (343,'2026-05-14 16:34:37.449107',451);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (344,'2026-05-14 16:49:36.358513',452);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (345,'2026-05-14 18:27:52.081836',453);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (346,'2026-05-15 03:30:23.236543',454);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (347,'2026-05-18 06:27:30.570273',456);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (348,'2026-05-18 06:28:36.973446',457);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (349,'2026-05-18 06:29:09.399356',459);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (350,'2026-05-18 06:31:46.480222',460);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (351,'2026-05-18 06:33:54.317498',461);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (352,'2026-05-18 06:35:23.155214',462);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (353,'2026-05-18 06:35:55.498217',463);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (354,'2026-05-18 06:38:14.991478',464);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (355,'2026-05-18 06:40:34.499348',465);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (356,'2026-05-18 08:12:37.509053',467);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (357,'2026-05-18 08:14:35.535004',466);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (358,'2026-05-18 08:20:13.435299',468);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (359,'2026-05-18 08:22:00.870286',471);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (360,'2026-05-18 08:22:56.834895',473);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (361,'2026-05-18 08:23:20.727198',472);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (362,'2026-05-18 08:25:45.300376',475);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (363,'2026-05-18 08:26:43.814256',476);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (364,'2026-05-18 08:29:03.575201',477);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (365,'2026-05-18 08:36:25.690703',478);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (366,'2026-05-18 09:25:23.633316',470);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (367,'2026-05-18 10:45:20.786867',480);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (368,'2026-05-19 11:39:48.644942',481);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (369,'2026-05-19 11:40:32.150440',487);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (370,'2026-05-19 15:10:07.478868',489);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (371,'2026-05-20 05:32:57.221409',455);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (372,'2026-05-22 19:09:28.115354',492);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (373,'2026-05-22 19:14:06.233347',493);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (374,'2026-05-23 03:43:33.135970',494);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (375,'2026-05-23 03:46:39.674174',495);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (376,'2026-05-23 04:00:13.429307',497);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (377,'2026-05-23 04:09:57.338094',498);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (378,'2026-05-23 04:13:58.538276',499);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (379,'2026-05-23 04:17:00.247615',500);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (381,'2026-05-23 04:18:29.228441',502);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (382,'2026-05-23 04:20:26.651223',503);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (383,'2026-05-23 04:21:00.328374',504);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (384,'2026-05-23 04:34:20.558477',505);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (386,'2026-05-23 04:47:30.304382',507);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (387,'2026-05-23 06:22:33.688936',508);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (388,'2026-05-23 09:34:24.778257',509);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (389,'2026-05-23 09:39:28.836026',510);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (390,'2026-05-23 10:50:36.642832',511);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (391,'2026-05-23 11:02:35.232466',512);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (392,'2026-05-23 11:03:06.164970',513);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (393,'2026-05-23 11:12:10.485413',514);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (395,'2026-05-23 11:40:11.555233',517);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (396,'2026-05-23 11:47:22.532622',520);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (397,'2026-05-23 13:05:14.096353',516);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (398,'2026-05-23 13:06:33.580667',524);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (399,'2026-05-23 13:07:06.550236',525);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (400,'2026-05-23 13:09:26.555403',526);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (401,'2026-05-23 13:11:25.652871',527);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (402,'2026-05-23 13:23:12.250626',528);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (403,'2026-05-23 17:10:51.187972',531);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (404,'2026-05-23 20:02:07.761156',533);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (405,'2026-05-23 20:17:11.798969',534);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (406,'2026-05-23 20:18:16.607958',535);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (407,'2026-05-23 20:18:40.021263',536);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (408,'2026-05-23 20:29:55.165842',537);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (409,'2026-05-23 20:58:50.237569',538);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (410,'2026-05-23 21:00:20.903592',539);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (411,'2026-05-24 03:13:24.077902',546);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (412,'2026-05-24 03:18:13.994615',547);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (413,'2026-05-24 04:05:26.316281',548);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (414,'2026-05-24 05:47:48.330768',554);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (415,'2026-05-24 05:49:04.382142',555);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (416,'2026-05-24 06:04:24.496526',552);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (417,'2026-05-24 06:05:06.733870',557);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (418,'2026-05-25 06:40:19.896157',559);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (419,'2026-05-25 07:36:21.209722',560);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (420,'2026-05-25 09:20:31.264130',571);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (421,'2026-05-25 16:00:04.437025',574);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (422,'2026-05-25 16:01:03.544320',575);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (423,'2026-05-25 16:07:05.536637',576);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (424,'2026-05-25 16:07:17.247465',577);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (425,'2026-05-25 16:23:50.328768',578);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (426,'2026-05-25 16:25:22.891586',579);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (427,'2026-05-25 16:35:55.542961',580);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (428,'2026-05-25 16:58:55.886037',582);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (429,'2026-05-25 17:28:01.945874',581);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (430,'2026-05-26 14:52:16.151521',586);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (431,'2026-05-27 02:48:50.332602',598);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (433,'2026-05-27 06:42:44.453028',600);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (435,'2026-05-27 07:23:33.142589',603);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (436,'2026-05-27 13:06:31.490666',605);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (438,'2026-05-28 17:08:25.075638',609);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (440,'2026-05-28 17:51:05.660000',614);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (442,'2026-05-29 05:55:07.218809',590);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (443,'2026-05-29 05:55:14.132762',624);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (444,'2026-05-29 06:06:50.231684',625);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (445,'2026-05-29 06:06:55.228475',627);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (446,'2026-05-29 06:15:10.232318',628);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (447,'2026-05-29 06:41:26.178152',629);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (448,'2026-05-29 06:42:13.800604',630);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (449,'2026-05-29 06:58:29.233772',632);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (450,'2026-05-29 10:19:52.816266',553);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (451,'2026-05-29 10:19:56.741293',633);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (452,'2026-05-29 10:20:00.374302',634);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (453,'2026-05-29 10:20:04.523313',635);
INSERT INTO `token_blacklist_blacklistedtoken` (`id`,`blacklisted_at`,`token_id`) VALUES (454,'2026-05-29 10:21:47.935553',636);

DROP TABLE IF EXISTS `token_blacklist_outstandingtoken`;
CREATE TABLE `token_blacklist_outstandingtoken` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `token` longtext NOT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `expires_at` datetime(6) NOT NULL,
  `user_id` bigint(20) DEFAULT NULL,
  `jti` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `token_blacklist_outstandingtoken_jti_hex_d9bdf6f7_uniq` (`jti`),
  KEY `token_blacklist_outstandingtoken_user_id_83bc629a_fk_users_id` (`user_id`),
  CONSTRAINT `token_blacklist_outstandingtoken_user_id_83bc629a_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=639 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (1,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzMzY0MCwiaWF0IjoxNzc4NDI4ODQwLCJqdGkiOiIyMzU1YTMyODQ1ZDU0N2MwYmFhOTBiYzM4MjRiZDUyYiIsInVzZXJfaWQiOiI0Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.c4jGUW2IMlWtVTMeB-P4JBObRYZlDsYq4OYh5HO9izA','2026-05-10 16:03:36.357241','2026-05-17 16:00:40',4,'2355a32845d547c0baa90bc3824bd52b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (2,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzMzgxNiwiaWF0IjoxNzc4NDI5MDE2LCJqdGkiOiI1NzliMTRmZGI2OTE0ZGEwODBhYTU0OWM1YzdkNTk4NSIsInVzZXJfaWQiOiI0Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.7KMqIJTqv2RPIZbE1pfUgOF-MF8eiXsVE6nR9G7GDGg','2026-05-10 16:03:36.357241','2026-05-17 16:03:36',4,'579b14fdb6914da080aa549c5c7d5985');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (3,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNDEzMywiaWF0IjoxNzc4NDI5MzMzLCJqdGkiOiIxYTc5MTc1ZTg0OTU0OWZkOGY0MGEzMzgyN2EyZDc2MSIsInVzZXJfaWQiOiI2In0.aqK9XVmOHbpPKacpnZ4PBX2Kdmb_VN_SOvcdbJTwQVc','2026-05-10 16:08:53.703837','2026-05-17 16:08:53',6,'1a79175e849549fd8f40a33827a2d761');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (4,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNDE0NSwiaWF0IjoxNzc4NDI5MzQ1LCJqdGkiOiJhZWNiMWViNjhkNzg0ZDE1YmM5N2Y5NGFlZTRiYjg3MyIsInVzZXJfaWQiOiI2In0.WJN5bhNi4BMTp8wuN3Aj-Egr0R6srwrzKCC3ILcorCQ','2026-05-10 16:09:05.489718','2026-05-17 16:09:05',6,'aecb1eb68d784d15bc97f94aee4bb873');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (5,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNDI4NCwiaWF0IjoxNzc4NDI5NDg0LCJqdGkiOiIyZGQyMDQyZjQ5ZGQ0NjRmYmY0MjI2ZGJlYjI0MWRjZSIsInVzZXJfaWQiOiI2In0.XofkQ3wZXkMCqLscwbc_rXPygjuud8w2C_HBIHv-ztw','2026-05-10 16:11:24.379242','2026-05-17 16:11:24',6,'2dd2042f49dd464fbf4226dbeb241dce');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (6,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNDMyMywiaWF0IjoxNzc4NDI5NTIzLCJqdGkiOiI1YTFiNGMwYTMxNjQ0ODEwODM5YjJmM2ZhNjAxZWVjZiIsInVzZXJfaWQiOiI3In0.cAC3G5MEBysVG-Oas6oEms_CjffmMYmrGa2kqXl2Dfs','2026-05-10 16:12:03.223338','2026-05-17 16:12:03',7,'5a1b4c0a31644810839b2f3fa601eecf');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (7,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNDYzMiwiaWF0IjoxNzc4NDI5ODMyLCJqdGkiOiIzZDY5ZjJmM2M4NjQ0Y2EwOGQ1YjBkNmUzZTVhMDE5MyIsInVzZXJfaWQiOiI4In0.fFRaZB2BlrgdY6lHPbdyxLTdY2ssaUqNC2NIAfoW6lc','2026-05-10 16:17:12.177364','2026-05-17 16:17:12',8,'3d69f2f3c8644ca08d5b0d6e3e5a0193');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (8,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNzQyNCwiaWF0IjoxNzc4NDMyNjI0LCJqdGkiOiIxYzc4NDgyMmVjMGE0NjVlYTQzMzZjYjg4ZThiMmU3NyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.ZejjFG0sKNAwPzUGBUOPcHrDt2dC5kJYFi_heJ6eft0','2026-05-10 17:03:44.145454','2026-05-17 17:03:44',8,'1c784822ec0a465ea4336cb88e8b2e77');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (9,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNzQzNiwiaWF0IjoxNzc4NDMyNjM2LCJqdGkiOiI4NTI5OWFkZmFjOTU0YzY5ODY3ZTZkZTBmOTA4YThmNSIsInVzZXJfaWQiOiI2In0.lJfKu7zlDQymmm9bJoWJH9wPVeXfW2_KBNvRHvvwYgs','2026-05-10 17:03:56.020324','2026-05-17 17:03:56',6,'85299adfac954c69867e6de0f908a8f5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (10,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNzQzOCwiaWF0IjoxNzc4NDMyNjM4LCJqdGkiOiI3OGE1MTA4ZTQ4NTE0NWRiYTU2NzVkOWQ0OTI3MDQ5OCIsInVzZXJfaWQiOiI2In0.fGQCVgJDE9027VgOiJqki1-nYZKQzRxIohATlb5AYBo','2026-05-10 17:03:58.084765','2026-05-17 17:03:58',6,'78a5108e485145dba5675d9d49270498');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (11,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNzg1OCwiaWF0IjoxNzc4NDMzMDU4LCJqdGkiOiI1Zjc3MmUyNTdhNjM0OTIxYTEzYjgwMThjMmE4Y2M3OSIsInVzZXJfaWQiOiI3In0.wkm05GDjBJ_73yo120cg4aVywdwHESqkXCuRm3Sb0uQ','2026-05-10 17:10:58.331713','2026-05-17 17:10:58',7,'5f772e257a634921a13b8018c2a8cc79');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (12,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzNzk3NiwiaWF0IjoxNzc4NDMzMTc2LCJqdGkiOiI4ZDVkOTYyNDkzNmQ0NzhjYjU1ODQ5Y2Q3ZjEyNTYxZCIsInVzZXJfaWQiOiI4In0.NoC1_86jBDqdka6rZVccW42rKuguq2znlCdNYYvHZNc','2026-05-10 17:12:56.840520','2026-05-17 17:12:56',8,'8d5d9624936d478cb55849cd7f12561d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (13,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzODEzMywiaWF0IjoxNzc4NDMzMzMzLCJqdGkiOiI1NDMxZDBmNGIwNmY0YTc4OGU1MGRjZDIzNmUxZmYwOCIsInVzZXJfaWQiOiI2In0.NwCF9jRhQw2SUN3yhPM94wIq-nt2PGsqNcQOj0XqRVc','2026-05-10 17:15:33.579206','2026-05-17 17:15:33',6,'5431d0f4b06f4a788e50dcd236e1ff08');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (14,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAzODI0NywiaWF0IjoxNzc4NDMzNDQ3LCJqdGkiOiI3MjA0ZmZiMDBlYTg0NjI4OTMwOWE2NzQwOTRkNGJkNCIsInVzZXJfaWQiOiI3In0.W7l1Aqffz2essphJ9_8G3tmcUJKeVgjUWqPuJToss6A','2026-05-10 17:17:27.033137','2026-05-17 17:17:27',7,'7204ffb00ea846289309a674094d4bd4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (15,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3NzYzMCwiaWF0IjoxNzc4NDcyODMwLCJqdGkiOiIzZjk1MmI0Y2RmOWQ0NDNhOTM4MjNkNjg4NTc4ZWVmNSIsInVzZXJfaWQiOiI4In0.BuG_frLN5dMxq_TsIb153NfZ4H_NWivgBCt5Q6vZuis','2026-05-11 04:13:50.171994','2026-05-18 04:13:50',8,'3f952b4cdf9d443a93823d688578eef5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (16,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3NzY4MCwiaWF0IjoxNzc4NDcyODgwLCJqdGkiOiIzODBkNDIwOGZhN2M0NjBhOTYxMjNjMzViMzk3NTk4YSIsInVzZXJfaWQiOiI2In0.OTidHomxeU-Y_-Civ8vQ-QxH1w1EZ0yXgnJsSPNGfk4','2026-05-11 04:14:40.565345','2026-05-18 04:14:40',6,'380d4208fa7c460a96123c35b397598a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (17,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3NzcyNywiaWF0IjoxNzc4NDcyOTI3LCJqdGkiOiIyMzhlZjA0ZjRkY2U0MWRmOWM2YWJkZjNlNzk2NTZhNiIsInVzZXJfaWQiOiI4In0.1oFbfzUag0voeA5sj8rQhQLGr8JI2EedMxlF_7zdP-g','2026-05-11 04:15:27.185226','2026-05-18 04:15:27',8,'238ef04f4dce41df9c6abdf3e79656a6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (18,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3Nzc5NiwiaWF0IjoxNzc4NDcyOTk2LCJqdGkiOiI3Zjg5NGQzN2Y3OTE0MmZmOGQxM2VlOTEwMDNmYjJhOSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.eF_5Muk8ISChCLEWZ5cQiWcGIZ_eIarLNbJYtlNBVKM','2026-05-11 04:16:36.688724','2026-05-18 04:16:36',8,'7f894d37f79142ff8d13ee91003fb2a9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (19,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3ODMyNSwiaWF0IjoxNzc4NDczNTI1LCJqdGkiOiI5NTkzNDFjOWVlOTc0YTc2YTE1NTk0YjkxZGJlMTIyYSIsInVzZXJfaWQiOiI4In0.rFA7iMfDVo0xSBwSI8B7xkSC_92_t9lkk38wGYk8zbA','2026-05-11 04:25:25.001156','2026-05-18 04:25:25',8,'959341c9ee974a76a15594b91dbe122a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (20,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3ODM2OSwiaWF0IjoxNzc4NDczNTY5LCJqdGkiOiJhZTEyNmQ1NTJiOTA0OGY5OWI2OWY1Nzc2ZmI3MGMyOSIsInVzZXJfaWQiOiI2In0.e7REW_tqn4bWtbBrfsnaE_ypHo4hkAiTz6oJPC-1afs','2026-05-11 04:26:09.064561','2026-05-18 04:26:09',6,'ae126d552b9048f99b69f5776fb70c29');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (21,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3ODQwOCwiaWF0IjoxNzc4NDczNjA4LCJqdGkiOiI1ZjcxZjAwOGRiY2I0MmQyOGZjZmViYTE4MTEzMmI1OSIsInVzZXJfaWQiOiI4In0._0n_D59wxkYNXqDmteOrr0Y0rBwWJM9pwZ56ytDQb-s','2026-05-11 04:26:48.692142','2026-05-18 04:26:48',8,'5f71f008dbcb42d28fcfeba181132b59');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (22,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTA2OCwiaWF0IjoxNzc4NDc0MjY4LCJqdGkiOiI0YzU5MTA0YTBmZDg0ZjhiOWU4YTE0OWEyMzA3NmFhOCIsInVzZXJfaWQiOiI3In0.DPgIl3FVf70ziLQszcs_TkAAsFsn22qKxpUG8mq_2Cs','2026-05-11 04:37:48.727992','2026-05-18 04:37:48',7,'4c59104a0fd84f8b9e8a149a23076aa8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (23,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTExNiwiaWF0IjoxNzc4NDc0MzE2LCJqdGkiOiJhOGNkNzQzZWJmNWQ0YzI1ODQwZWM5MDRjODE3ZTM0OCIsInVzZXJfaWQiOiI2In0.ePErjggoHCkaLoiwSQ7FBfmxPba4vVrQom9y1wggUSM','2026-05-11 04:38:36.151875','2026-05-18 04:38:36',6,'a8cd743ebf5d4c25840ec904c817e348');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (24,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTEzMywiaWF0IjoxNzc4NDc0MzMzLCJqdGkiOiIyMzY5OWYyYjEzODM0MjQ3YWU2MWZlZGU5OGQwY2NmZSIsInVzZXJfaWQiOiI4In0.UK5Vq59rnBgycN5_Rveev6MVx2x8ss6D7pLXQFDDX1k','2026-05-11 04:38:53.213127','2026-05-18 04:38:53',8,'23699f2b13834247ae61fede98d0ccfe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (25,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTIwNywiaWF0IjoxNzc4NDc0NDA3LCJqdGkiOiI5NzIxYmE1ZTg0ODE0ZjA5Yjg4NWQ2MDlmNDhhYjMzOCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.BLYybJNqm2PdenUMDvZwFNWfp8QrMftUfIDqFDNSAEc','2026-05-11 04:40:07.331602','2026-05-18 04:40:07',8,'9721ba5e84814f09b885d609f48ab338');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (26,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTI5NiwiaWF0IjoxNzc4NDc0NDk2LCJqdGkiOiI1OGNjZDliMmYzYmU0N2I5YTgwNjVkOTNiZGExMDZiOCIsInVzZXJfaWQiOiI2In0.XiVjdblF5wQBe-WgGaJWCmycGgiYmONeehfoqdtgMPY','2026-05-11 04:41:36.372329','2026-05-18 04:41:36',6,'58ccd9b2f3be47b9a8065d93bda106b8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (27,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTQ5NSwiaWF0IjoxNzc4NDc0Njk1LCJqdGkiOiJlMjY1MWRjMzM1ODA0NjVmYWYxNTUwYzA1ZTRkMjFhMiIsInVzZXJfaWQiOiI4In0.Fp_zhkH7E0rXoilwOipFkIgIPxCA53XkVBRfyyRcL2A','2026-05-11 04:44:55.524316','2026-05-18 04:44:55',8,'e2651dc33580465faf1550c05e4d21a2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (28,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTU3MSwiaWF0IjoxNzc4NDc0NzcxLCJqdGkiOiJmMDNiMmYxNzJiYTg0OWQ5ODQzNTM4YWFmNWFhYzIxZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.qC52cAOJyXIdveCIMVV8wec7-iypnPsqMVo66dLQVxQ','2026-05-11 04:46:11.362485','2026-05-18 04:46:11',8,'f03b2f172ba849d9843538aaf5aac21f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (29,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA3OTY4NiwiaWF0IjoxNzc4NDc0ODg2LCJqdGkiOiI4Mjk4ZTZiMjNlNjc0MGUzODlkNzQ4YmRiYTMyNTdjZiIsInVzZXJfaWQiOiI2In0.ivje0jGa61OXcUqm4p8WDh2Ke3wbU_EO11e46Xvwel4','2026-05-11 04:48:06.215394','2026-05-18 04:48:06',6,'8298e6b23e6740e389d748bdba3257cf');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (30,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDMyOSwiaWF0IjoxNzc4NDc1NTI5LCJqdGkiOiI3YzE2NGRkN2M2M2I0NTUyYWMyMTc5M2U4YzMxM2Y1NSIsInVzZXJfaWQiOiI4In0.axhLc33M8fFrt_hO_gmvkXH5GNgkPjA_qlyzvzeR2YI','2026-05-11 04:58:49.899320','2026-05-18 04:58:49',8,'7c164dd7c63b4552ac21793e8c313f55');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (31,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDQ2NywiaWF0IjoxNzc4NDc1NjY3LCJqdGkiOiI3YzIxYzQ5NzJiM2U0OGZhYmNjMDY5ODg4ODQ3NTk5OSIsInVzZXJfaWQiOiI4In0.5Gw6UzTrHCEWGWsnfmw8iDL8Nv4-Q2xpi41FFTU7mn8','2026-05-11 05:01:07.272512','2026-05-18 05:01:07',8,'7c21c4972b3e48fabcc0698888475999');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (32,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDQ4NCwiaWF0IjoxNzc4NDc1Njg0LCJqdGkiOiJhODg1ZjQwODk5NjQ0YmMwOGM0NGEzMTE4YzQ0YjgzZSIsInVzZXJfaWQiOiI4In0.XMIvA7vKer46zN7DJpoU0P1rzdPML8V_TxSeMHLhPW8','2026-05-11 05:01:24.887574','2026-05-18 05:01:24',8,'a885f40899644bc08c44a3118c44b83e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (33,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDQ5OCwiaWF0IjoxNzc4NDc1Njk4LCJqdGkiOiJhNGFmNDdhOTQ1MjM0MTljOWY5MDdlYjk5Y2VjZDJjNiIsInVzZXJfaWQiOiI4In0.-EL45Oeh328-vVl4LOUpPfKqSQfL2YM6_DKb8HPx_cM','2026-05-11 05:01:38.960391','2026-05-18 05:01:38',8,'a4af47a94523419c9f907eb99cecd2c6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (34,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDYzMCwiaWF0IjoxNzc4NDc1ODMwLCJqdGkiOiJjMTdiMDdjNzdjNDQ0MDIzOWJlYmE2M2Q2NzNhNmQ5MyIsInVzZXJfaWQiOiI4In0.LfffvbTRoSa1s9mJw9fNBHWsCPvZ4FtEcC4s7rTk2mg','2026-05-11 05:03:50.142923','2026-05-18 05:03:50',8,'c17b07c77c4440239beba63d673a6d93');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (35,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDY0NiwiaWF0IjoxNzc4NDc1ODQ2LCJqdGkiOiIwOTA3MWU1OWU2YWY0NWVkYmU3NTE4ZGQzMjlhYWJlZiIsInVzZXJfaWQiOiI4In0.UE88B6z264I-yKX1Z1x-pAYeEUOPTM2z9tpHZYUIf5c','2026-05-11 05:04:06.407256','2026-05-18 05:04:06',8,'09071e59e6af45edbe7518dd329aabef');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (36,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDY2MiwiaWF0IjoxNzc4NDc1ODYyLCJqdGkiOiI1Nzk1NTkxNGM3MzQ0OTdlYjU5YjYxMmNiNWViOTEyOSIsInVzZXJfaWQiOiI4In0.jlsvxVCh2ZCPK04esPw-M22BJegoeOlGvdNkb6EXaBU','2026-05-11 05:04:22.219287','2026-05-18 05:04:22',8,'57955914c734497eb59b612cb5eb9129');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (37,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDY3OCwiaWF0IjoxNzc4NDc1ODc4LCJqdGkiOiJiZDdiNWFjMGM5NDA0ZTFkYWNlNzlmODdmY2U4ZmM0YiIsInVzZXJfaWQiOiI4In0.dUFIihtVtuFJ7ui9booK0knjN--c_GwIoFKctaT0XyE','2026-05-11 05:04:38.346581','2026-05-18 05:04:38',8,'bd7b5ac0c9404e1dace79f87fce8fc4b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (38,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDc0OCwiaWF0IjoxNzc4NDc1OTQ4LCJqdGkiOiI4YWZkNDhkM2FiMTA0ZWJhOWRjNThiZWY1YzFiNzE4NCIsInVzZXJfaWQiOiI4In0.eaQAzFIN3_T_AQshiGkzYD_o8qSi2iykXMkPYIKYrlg','2026-05-11 05:05:48.062515','2026-05-18 05:05:48',8,'8afd48d3ab104eba9dc58bef5c1b7184');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (39,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDc1MSwiaWF0IjoxNzc4NDc1OTUxLCJqdGkiOiJmMWU0ZDQ3YTdkODM0ZGQ5ODBjZThmZWQwODgzZjk1NyIsInVzZXJfaWQiOiI2In0.llDUqa9YuGOGsX-JpQTqwCnSHXvX_2gTt1wBr8vYwr8','2026-05-11 05:05:51.645970','2026-05-18 05:05:51',6,'f1e4d47a7d834dd980ce8fed0883f957');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (40,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDgwNSwiaWF0IjoxNzc4NDc2MDA1LCJqdGkiOiI0Y2JlMzg3ZDdhMzU0OGU3YjQ1MWYxODg0MGRhOGM5OCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.TsNLDBLQ6hEJZl5gBsSKmz3syPziVp-Y1DrZpVZIMw8','2026-05-11 05:06:45.690132','2026-05-18 05:06:45',8,'4cbe387d7a3548e7b451f18840da8c98');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (41,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDg4OCwiaWF0IjoxNzc4NDc2MDg4LCJqdGkiOiIzZDE4MmM4NTk5MTg0MDQ1YjUzMDRhNmIxNGQ3YjZkNyIsInVzZXJfaWQiOiI2In0.Hqt7IjMMYlJ2IYWK3NX9wQ1xS5hWPhIG6jjaOdwnt64','2026-05-11 05:08:08.348961','2026-05-18 05:08:08',6,'3d182c8599184045b5304a6b14d7b6d7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (42,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDk0NSwiaWF0IjoxNzc4NDc2MTQ1LCJqdGkiOiI1YzllZmZkNjVkM2U0OWIzOGJjM2RlYjUzYjU4ZTRmMCIsInVzZXJfaWQiOiI4In0.DEX2gkZ76Ih0pkf9nN8ocrBYto-1A5Uu0i0xGRAaV90','2026-05-11 05:09:05.907642','2026-05-18 05:09:05',8,'5c9effd65d3e49b38bc3deb53b58e4f0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (43,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MDk3MiwiaWF0IjoxNzc4NDc2MTcyLCJqdGkiOiI5NDc3MjBhM2QyY2Y0MzQyYTZmYzUyMjNkZGQyMmYwZiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.hBPE0sI-BnBbbrN96Ix_S8FDu53O0LbfZDF35xYsflg','2026-05-11 05:09:32.957648','2026-05-18 05:09:32',6,'947720a3d2cf4342a6fc5223ddd22f0f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (44,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTE0MywiaWF0IjoxNzc4NDc2MzQzLCJqdGkiOiJhYzdmMmIxYmM1MDA0YmJmYjk0YmUwZjMyOTg0YjcwOSIsInVzZXJfaWQiOiI4In0.g5J78-T7X39sjBhsN8ScwPFKjLOa1Rgo5tA1Ilaj498','2026-05-11 05:12:23.282891','2026-05-18 05:12:23',8,'ac7f2b1bc5004bbfb94be0f32984b709');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (45,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTE0NywiaWF0IjoxNzc4NDc2MzQ3LCJqdGkiOiJjMWEyNzg5MDUxNzk0MDcyODQzYTgyNDliODZjZDljZSIsInVzZXJfaWQiOiI2In0.s9BITPVwDjTVK981U6WDKmRvSvDfEHBEtLZ8sCnUs7o','2026-05-11 05:12:27.306539','2026-05-18 05:12:27',6,'c1a2789051794072843a8249b86cd9ce');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (46,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTE4MCwiaWF0IjoxNzc4NDc2MzgwLCJqdGkiOiJkY2I0YmM2NTdmYWY0ZjM3Yjk4NDViMzBmZDBjMzJkNiIsInVzZXJfaWQiOiI2In0._FE4Mu5LMfq7_W_dL3C4v2AE0A3o41TKVwDpSyxnikI','2026-05-11 05:13:00.805886','2026-05-18 05:13:00',6,'dcb4bc657faf4f37b9845b30fd0c32d6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (47,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTIzNiwiaWF0IjoxNzc4NDc2NDM2LCJqdGkiOiJjNjEwMDU4MTgxNDI0ZTY0OWQxNGQ2ZDA4OWI0YjMzMSIsInVzZXJfaWQiOiI4In0.0U98-dBbCFecrO8gKnPlabQZMMJ1KqC0q96EIrDzJ9c','2026-05-11 05:13:56.232752','2026-05-18 05:13:56',8,'c610058181424e649d14d6d089b4b331');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (48,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTI5MiwiaWF0IjoxNzc4NDc2NDkyLCJqdGkiOiJkZGU4ODUxYWFhMTk0MDA1OWU3NDZkYWZlM2Q0ZWY0ZiIsInVzZXJfaWQiOiI2In0.vrnV-Eqqc5snnpVB6JRZLxOvq3zj0RTGZLEM28etqvw','2026-05-11 05:14:52.656781','2026-05-18 05:14:52',6,'dde8851aaa1940059e746dafe3d4ef4f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (49,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTUzMiwiaWF0IjoxNzc4NDc2NzMyLCJqdGkiOiI2YzYyMWUxNTE2NjI0ZDlhYTI4ODE4NGRjNjk2OTQ0NCIsInVzZXJfaWQiOiI2In0.KJdn7Xj5-CsUrhYkIQKJNFlLI_2S8DVCQ_eMSXv5pK8','2026-05-11 05:18:52.598920','2026-05-18 05:18:52',6,'6c621e1516624d9aa288184dc6969444');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (50,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTU1MCwiaWF0IjoxNzc4NDc2NzUwLCJqdGkiOiIwYTJhZTI0OGViMWE0YjJiOTU5NDgwNDNiMjIwNzFhOSIsInVzZXJfaWQiOiI2In0.0jgDVPiTCCx4o4hXiExC6xQVvwS1DIyqxPPe3NAwxK0','2026-05-11 05:19:10.767023','2026-05-18 05:19:10',6,'0a2ae248eb1a4b2b95948043b22071a9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (51,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTY3OSwiaWF0IjoxNzc4NDc2ODc5LCJqdGkiOiJlY2RjNGJhY2M1YzY0NTExYjk5Y2UyNjJiZjdlNzIyZCIsInVzZXJfaWQiOiI2In0.im4vC2475tN283WVUNDJXwXYOHyw-VULpe4xE7ba0zQ','2026-05-11 05:21:19.830911','2026-05-18 05:21:19',6,'ecdc4bacc5c64511b99ce262bf7e722d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (52,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTY5NSwiaWF0IjoxNzc4NDc2ODk1LCJqdGkiOiJjMDBiOTgyYjlmMzg0NTZmYTM3MWMzODBlNzU0MzdkOSIsInVzZXJfaWQiOiI2In0.gvrAleenJ_iRWVyPGnizZ7-QGjcCi6zxeRB7hk5_6r4','2026-05-11 05:21:35.348346','2026-05-18 05:21:35',6,'c00b982b9f38456fa371c380e75437d9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (53,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTcxNiwiaWF0IjoxNzc4NDc2OTE2LCJqdGkiOiIwMmJmYzI4ZmMyYzI0MTMwOTFmZWI3N2UxODdjYzliNiIsInVzZXJfaWQiOiI2In0.ffHbXzVMUJJsDxNnuP_fZhwgb6Xa80cNjKFHARMYNqY','2026-05-11 05:21:56.074664','2026-05-18 05:21:56',6,'02bfc28fc2c2413091feb77e187cc9b6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (54,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTc3NywiaWF0IjoxNzc4NDc2OTc3LCJqdGkiOiJiMmMyYzdkYTc5Mjg0NzcyOTVjNjNhMjNmYWFkOTZmMCIsInVzZXJfaWQiOiI4In0.dMbnR2uonj7sN2LTH7ITQ-rRc0H6rbq8ZNBFHHSvCrQ','2026-05-11 05:22:57.085804','2026-05-18 05:22:57',8,'b2c2c7da7928477295c63a23faad96f0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (55,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MTc5MiwiaWF0IjoxNzc4NDc2OTkyLCJqdGkiOiI0MzY3NmY1NTI0YTU0NDAyOThlYTYxYzJiYTBkNzcxMiIsInVzZXJfaWQiOiI2In0.BmJaUlMGYOsquqXJwQNK8A6BlxdxdwGOS5K6uIdREzY','2026-05-11 05:23:12.343612','2026-05-18 05:23:12',6,'43676f5524a5440298ea61c2ba0d7712');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (56,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MjMyMSwiaWF0IjoxNzc4NDc3NTIxLCJqdGkiOiJhYmJkYzBmN2MwZjM0ZWI1OWVlMzU3N2I4NjcxZGY2NyIsInVzZXJfaWQiOiI3In0.QZkj8J55xJNKnulUVrRdcvpi6uYlgS-VKRCtLRdYh2E','2026-05-11 05:32:01.529607','2026-05-18 05:32:01',7,'abbdc0f7c0f34eb59ee3577b8671df67');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (57,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MjM4OSwiaWF0IjoxNzc4NDc3NTg5LCJqdGkiOiI4ZTEwNTE4OTZkMGE0MjJkOGFlNTc1YmQ0MDRlYjhkNCIsInVzZXJfaWQiOiI2In0.JqakHMfWkgS99bMV_N98bLK_-pmzls79yLFhq8J0l_w','2026-05-11 05:33:09.198041','2026-05-18 05:33:09',6,'8e1051896d0a422d8ae575bd404eb8d4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (58,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MjQxNCwiaWF0IjoxNzc4NDc3NjE0LCJqdGkiOiI5ZDhiMTk4ZGE5NjY0OWY4YTAzOGE4MDQ3YjA1YzcwMCIsInVzZXJfaWQiOiI3In0.E_pCx1Bkd_UyfwYj7rSlu1LEj-Y-ADlUWcdd3km34aU','2026-05-11 05:33:34.172300','2026-05-18 05:33:34',7,'9d8b198da96649f8a038a8047b05c700');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (59,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4MjUwOCwiaWF0IjoxNzc4NDc3NzA4LCJqdGkiOiIxMjNiMjIyYTc2MzQ0ZjkyOWUzMzc3OTgyOGM2NmM5MiIsInVzZXJfaWQiOiI2In0.q58yx5ByODGVbJCePUYcGCy9QZ_Emzg85MVYB6LjxtY','2026-05-11 05:35:08.174448','2026-05-18 05:35:08',6,'123b222a76344f929e33779828c66c92');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (60,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTA4NywiaWF0IjoxNzc4NDg0Mjg3LCJqdGkiOiJjMWVhMTc2NjliNGM0ZGVlYmViMjczMDcyMWFhNTIxOSIsInVzZXJfaWQiOiI3In0.QIXkcUHw2i3M-JzLbH2yZeZIhNdkiMSBqZ2XLD5PyNE','2026-05-11 07:24:47.012482','2026-05-18 07:24:47',7,'c1ea17669b4c4deebeb2730721aa5219');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (61,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTEwNiwiaWF0IjoxNzc4NDg0MzA2LCJqdGkiOiI3MjVkNDQ2MzM5Mjg0NjlhOGRjZDc0MzIzMDVkMjQ2MCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.Ipyir-iPkZkJI3Gq3vWTDHWHZNBSmhSQmhaV6tA76qM','2026-05-11 07:25:06.515565','2026-05-18 07:25:06',7,'725d44633928469a8dcd7432305d2460');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (62,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTQwMCwiaWF0IjoxNzc4NDg0NjAwLCJqdGkiOiJiNDFlZjM0ZmQyZGE0N2JkODk3Mzc3OTNlZTMzZmIwYiIsInVzZXJfaWQiOiI2In0.MWFwiswekkl8_qwr_JTyoQ2_HJIfEm-aXtpFC8WECtI','2026-05-11 07:30:00.325952','2026-05-18 07:30:00',6,'b41ef34fd2da47bd89737793ee33fb0b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (63,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTUyNCwiaWF0IjoxNzc4NDg0NzI0LCJqdGkiOiI5MmFiN2ZkZWQ5ZjU0ZDI1YjJlYWFjODdhNDJmZmYwZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.ThLYX_E6RN0AfQb-pEcRitUXj_qiFeO2gsBG8YbRyA0','2026-05-11 07:32:04.890404','2026-05-18 07:32:04',6,'92ab7fded9f54d25b2eaac87a42fff0d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (64,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTY5MiwiaWF0IjoxNzc4NDg0ODkyLCJqdGkiOiI3NzI4ZWNiNzU4Mzk0MDhjYWRjYmIwYzkzMTBmMzZhMCIsInVzZXJfaWQiOiI4In0.FJRguZ3iweuHCc9LJI7VYyAIss2MkpKUB0Iuystym5U','2026-05-11 07:34:52.293715','2026-05-18 07:34:52',8,'7728ecb75839408cadcbb0c9310f36a0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (65,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTcwOCwiaWF0IjoxNzc4NDg0OTA4LCJqdGkiOiI1NWViNmNhYjg0YTM0YWIwYmM4YzU4MTFmN2I1ZjFmMSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0._RRX7M-gQhEm9fpaNW6fGCp0YNj7W5yryoCc_2iMHo4','2026-05-11 07:35:08.439125','2026-05-18 07:35:08',8,'55eb6cab84a34ab0bc8c5811f7b5f1f1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (66,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTk2MiwiaWF0IjoxNzc4NDg1MTYyLCJqdGkiOiI2ZmU4M2I4ZDIyYmU0NWVlYmY4ZmZhOTA3NmZmMTg4NSIsInVzZXJfaWQiOiI3In0.fqyUbr3uUe9hD6GUpAf71PBLinwwhCdh_QVwkLXkcbs','2026-05-11 07:39:22.780218','2026-05-18 07:39:22',7,'6fe83b8d22be45eebf8ffa9076ff1885');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (67,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTk3NCwiaWF0IjoxNzc4NDg1MTc0LCJqdGkiOiIxMzUwYTU3MTU3YWI0ZmU2OGYyOWEyMTUxMDM3ZmJhZSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.NPSS9ZLypYBUkhU-AlSqOvTuC9i3DX4--gmMaqXILps','2026-05-11 07:39:34.533642','2026-05-18 07:39:34',7,'1350a57157ab4fe68f29a2151037fbae');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (68,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA4OTk5OCwiaWF0IjoxNzc4NDg1MTk4LCJqdGkiOiJjMzFhOTA4ZDliN2Y0NTc4OTdmOGZlNTZiNjdkOTg5OCIsInVzZXJfaWQiOiI2In0.cVc4yf9SE3iJDzM8WkkA7SCrUThWOvEPVlg8oUJLA5s','2026-05-11 07:39:58.368601','2026-05-18 07:39:58',6,'c31a908d9b7f457897f8fe56b67d9898');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (69,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MDEwNywiaWF0IjoxNzc4NDg1MzA3LCJqdGkiOiI5YjIzMGVlZDAwMzc0ZTRhYTJiYTkwZjk3MTIxZDBlNCIsInVzZXJfaWQiOiI4In0.U_NyYeEpDYDeG-60e2yPUh1S5YeDXVrKjzWDfZucMG8','2026-05-11 07:41:47.214111','2026-05-18 07:41:47',8,'9b230eed00374e4aa2ba90f97121d0e4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (70,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MDI0MCwiaWF0IjoxNzc4NDg1NDQwLCJqdGkiOiJiMmY1M2M1Nzg3ZjI0MGQ0YmI5NjUzMDk5Nzk2Yjk1NiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0._STEjbZenR_FOLajdneLDaI3HrasRYxkLl5S3VgevVY','2026-05-11 07:44:00.001126','2026-05-18 07:44:00',8,'b2f53c5787f240d4bb9653099796b956');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (71,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MjE0NCwiaWF0IjoxNzc4NDg3MzQ0LCJqdGkiOiJkNzIyNDU4M2EzZWM0ZjVlOGRkYTk5MzQwNzU1YzFiMCIsInVzZXJfaWQiOiI2In0.R-3KaYlzRDozz8ysBgd1Rrv1NSL_Xd0CkyDd7Ta5X20','2026-05-11 08:15:44.928829','2026-05-18 08:15:44',6,'d7224583a3ec4f5e8dda99340755c1b0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (72,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MjE0NywiaWF0IjoxNzc4NDg3MzQ3LCJqdGkiOiJmYTgwMzlmNDEwMGM0NmU5ODAyNDcyMjliOTJiZDcyOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.0aKdi5BGH5qoqYBXmWWiP0_UC8-jnMVSTcjhTj54dho','2026-05-11 08:15:47.523257','2026-05-18 08:15:47',6,'fa8039f4100c46e980247229b92bd729');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (73,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MjU5MSwiaWF0IjoxNzc4NDg3NzkxLCJqdGkiOiIwNjI3Mzc4MDlhNzA0ODZiYWY1ZWMxZDJlM2JiOGU3NyIsInVzZXJfaWQiOiI5In0.k6LrY8Wnfuisq4HH2j6YC3FDMb9w6PVzJ3EyZ38DGnA','2026-05-11 08:23:11.012729','2026-05-18 08:23:11',9,'062737809a70486baf5ec1d2e3bb8e77');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (74,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MjYxNiwiaWF0IjoxNzc4NDg3ODE2LCJqdGkiOiI3MTRjMmZjZmRlY2Y0YzcwYjMxYzgyY2M4MDEyNDk3YyIsInVzZXJfaWQiOiI2In0.BC9lJHJxDOtocGquUd8cTXmIb_ypbkORCbuSI5M7A40','2026-05-11 08:23:36.405471','2026-05-18 08:23:36',6,'714c2fcfdecf4c70b31c82cc8012497c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (75,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5Mjc0OCwiaWF0IjoxNzc4NDg3OTQ4LCJqdGkiOiJmMDdmYTlmMjRlMTQ0YzliYjYxZmFiZjVjNWMwYTkxZSIsInVzZXJfaWQiOiI5Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6InRlc3RmdW5jQGV4YW1wbGUuY29tIn0.rdIoJOb4VfhDMXMrbo39-SY3Kmo7zaWm05eDvB5tx8E','2026-05-11 08:25:48.631392','2026-05-18 08:25:48',9,'f07fa9f24e144c9bb61fabf5c5c0a91e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (76,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5Mjc3MywiaWF0IjoxNzc4NDg3OTczLCJqdGkiOiIzZWFhYmE4NmI5MzI0NWM0YTA1NGM5YzExMmI4ZjIwMCIsInVzZXJfaWQiOiI5In0.b2LAC1YGtc9dgcCO0CaTqxHYX4Pbg9DViqHx9TzXpiA','2026-05-11 08:26:13.406492','2026-05-18 08:26:13',9,'3eaaba86b93245c4a054c9c112b8f200');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (77,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5Mjc4OSwiaWF0IjoxNzc4NDg3OTg5LCJqdGkiOiJmOTY3NGMwMzViOTU0OWMwYTIwZGRjMjMyZmJkMzk1MyIsInVzZXJfaWQiOiI5Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6InRlc3RmdW5jQGV4YW1wbGUuY29tIn0.Vgo4rnqEzP7a6kND9T9VVxtGyuap20s8zuPcba0_-7s','2026-05-11 08:26:29.433601','2026-05-18 08:26:29',9,'f9674c035b9549c0a20ddc232fbd3953');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (78,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MzAzMiwiaWF0IjoxNzc4NDg4MjMyLCJqdGkiOiI0OGJhMDRiZGM0ZjQ0ZGI2OTdiOGJiZTY3OTY0MGMzMyIsInVzZXJfaWQiOiI2In0.GArZs5V0rAOxLRzSvPC8WKUWlKPsm4oZatFZ8LS8vyM','2026-05-11 08:30:32.113267','2026-05-18 08:30:32',6,'48ba04bdc4f44db697b8bbe679640c33');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (79,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5MzAzNCwiaWF0IjoxNzc4NDg4MjM0LCJqdGkiOiJhMTY5ZDAzNjdmNGU0MjFiYTBiNDdhNjQyYTg1MGMzYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.ZDnRIdY4RafBqgIF-5kX3zwj-5SR4QCq96L4Y7hP9do','2026-05-11 08:30:34.902895','2026-05-18 08:30:34',6,'a169d0367f4e421ba0b47a642a850c3a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (80,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDA5NSwiaWF0IjoxNzc4NDg5Mjk1LCJqdGkiOiJjYzZlNWIyZDE4NTQ0YTA4OGQzMDViYjU5ODliNDZjZCIsInVzZXJfaWQiOiI3In0.a8fCZFQ8s9b_O2vj7A8fhnKwX0Y9JmUfzUdpCTPgvI4','2026-05-11 08:48:15.173870','2026-05-18 08:48:15',7,'cc6e5b2d18544a088d305bb5989b46cd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (81,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDEwMywiaWF0IjoxNzc4NDg5MzAzLCJqdGkiOiI4NzJkMjI5NzhlNzM0ZjJiODI0NTQ3ZDE5NzFkMTU1MiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.hQuW3QiyRzCo9PJiHo1NA3OpTehYp-iRpuso_j8no6w','2026-05-11 08:48:23.937814','2026-05-18 08:48:23',7,'872d22978e734f2b824547d1971d1552');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (82,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDE1OCwiaWF0IjoxNzc4NDg5MzU4LCJqdGkiOiJmYTRmZjUxYTFhYTU0NDFjODVmYTgyNzkwYzNiOTY5MiIsInVzZXJfaWQiOiI2In0.wOAOwYqbE4oL7DsO_WUqoxFlDy9GC3TU5v_BHAhxpkE','2026-05-11 08:49:18.046772','2026-05-18 08:49:18',6,'fa4ff51a1aa5441c85fa82790c3b9692');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (83,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDE2NSwiaWF0IjoxNzc4NDg5MzY1LCJqdGkiOiIwZjFjNWZkZjA4OGY0Y2U0YWEzNzFhNjRhMDkxYzg1NSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Xws0RMmjI1Dj6tmzGxxxmHCOaX26DUUGm7bLVGkRihk','2026-05-11 08:49:25.219128','2026-05-18 08:49:25',6,'0f1c5fdf088f4ce4aa371a64a091c855');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (84,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDIyOCwiaWF0IjoxNzc4NDg5NDI4LCJqdGkiOiI2N2I2YzdiMDg2N2M0NjdkOWM2YWM4YjliMmE2YWMzZiIsInVzZXJfaWQiOiI3In0.ExfB21rxjiHrWDpMeDKiAsMJyECsLdDgPKtCepeXt44','2026-05-11 08:50:28.072872','2026-05-18 08:50:28',7,'67b6c7b0867c467d9c6ac8b9b2a6ac3f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (85,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDI4MSwiaWF0IjoxNzc4NDg5NDgxLCJqdGkiOiI1NGJlYTM5NTQxNzY0YTQxOWZjOWFiNTNkYTI2MTc5YyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.0E4uhFSqq781JnKvmBxbOG0csie7bnaaeAScMZ-lWQQ','2026-05-11 08:51:21.686716','2026-05-18 08:51:21',7,'54bea39541764a419fc9ab53da26179c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (86,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDM0MSwiaWF0IjoxNzc4NDg5NTQxLCJqdGkiOiI0YzZlYmNkNzBkNmM0NmFlYjQ0NzJjNjEyZmUyNThhNCIsInVzZXJfaWQiOiI4In0.oLm8IRMBUGxRU2fiVqtZRASkCWo9UqATOBnjhPc0grg','2026-05-11 08:52:21.313661','2026-05-18 08:52:21',8,'4c6ebcd70d6c46aeb4472c612fe258a4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (87,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDM2MiwiaWF0IjoxNzc4NDg5NTYyLCJqdGkiOiIwNjE3MDkwMzBjZGM0ZGJmOWQ0MTE5MTkyNDIyNjY0YSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.BIBkZf4-ySiMN7n-JabY7JqCA-aaAhNyteZGn1Tsf-s','2026-05-11 08:52:42.497953','2026-05-18 08:52:42',8,'061709030cdc4dbf9d4119192422664a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (88,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDQ1NywiaWF0IjoxNzc4NDg5NjU3LCJqdGkiOiIwMzcwY2RlOWM3Y2M0NGM2YWZjNTdiYjBiZWEwYmEyZSIsInVzZXJfaWQiOiI3In0.VLV81_u2hSM4J1jTsNDpybzjQkFmcFGdSLCNIHnrx5E','2026-05-11 08:54:17.427838','2026-05-18 08:54:17',7,'0370cde9c7cc44c6afc57bb0bea0ba2e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (89,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDUxNSwiaWF0IjoxNzc4NDg5NzE1LCJqdGkiOiI0MjBjODdjOWJhMTQ0MWZiYTZhMTQzMjc0NTIzYjE0YiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.MMzNIRZNXbhnUK7xLRL_e7_kQDYCOZ-PbGtD-QWBybk','2026-05-11 08:55:15.889813','2026-05-18 08:55:15',7,'420c87c9ba1441fba6a143274523b14b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (90,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDYwOSwiaWF0IjoxNzc4NDg5ODA5LCJqdGkiOiI5OTlkMTRmNWExMTI0NGQ1YjU1NzYxZjM1ZmE0YmEwMSIsInVzZXJfaWQiOiI4In0.vYcJCuAyw4RJXJztpEplNr-gURFJd4qTC310I6gg2Sw','2026-05-11 08:56:49.968768','2026-05-18 08:56:49',8,'999d14f5a11244d5b55761f35fa4ba01');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (91,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDY5MywiaWF0IjoxNzc4NDg5ODkzLCJqdGkiOiI1Nzg2NmZkZWE4M2Q0MjdjOTBiNjI1OWFmZTA4NDc1ZiIsInVzZXJfaWQiOiI3In0.FIJVG-7vzdboqJS01GOAgVuEXplAfGQhqNDNUkPYtAo','2026-05-11 08:58:13.314985','2026-05-18 08:58:13',7,'57866fdea83d427c90b6259afe08475f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (92,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDY5OCwiaWF0IjoxNzc4NDg5ODk4LCJqdGkiOiIwNzlhOTFkMDEyMDk0MWZjODNhYzE0NDMwZWNmODhlNyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.D02rqobSYv0zs4VuMtMhUFG3zi6Co6Q_bwK0fx8y_Dc','2026-05-11 08:58:18.957587','2026-05-18 08:58:18',7,'079a91d0120941fc83ac14430ecf88e7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (93,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDkxNCwiaWF0IjoxNzc4NDkwMTE0LCJqdGkiOiIxMmIwMGRkZWVlYjU0ZTUxOGI5OGY2YTczMjZhOWNkNSIsInVzZXJfaWQiOiI2In0.3XJcVzC0NDd6eL5EqfKS_v0ZOaxnAyzDVJpK-U0xg6U','2026-05-11 09:01:54.679866','2026-05-18 09:01:54',6,'12b00ddeeeb54e518b98f6a7326a9cd5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (94,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NDkyMCwiaWF0IjoxNzc4NDkwMTIwLCJqdGkiOiIxZDBhNjUxMGIxMDQ0OGViOTdkYmNiMDE0YmViMjJkNSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.EBHRIHWF1EsW31nX6mtOtgU13OdezKZX0tB7Hpjiivk','2026-05-11 09:02:00.548995','2026-05-18 09:02:00',6,'1d0a6510b10448eb97dbcb014beb22d5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (95,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTAyMywiaWF0IjoxNzc4NDkwMjIzLCJqdGkiOiI2YmMxZmNkMGUyMTQ0ZDIxYWI2ZmJjMjI1ZGJjOWI1OCIsInVzZXJfaWQiOiI3In0.RRpRj2TnUirzRoMhIPOMYmVNpYLOgheqSWXMz1viSLc','2026-05-11 09:03:43.713911','2026-05-18 09:03:43',7,'6bc1fcd0e2144d21ab6fbc225dbc9b58');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (96,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTA4NCwiaWF0IjoxNzc4NDkwMjg0LCJqdGkiOiIyNmJiNDQwZmZiNWI0YTZkOGYxZGM4NjU5YjJiM2Y5YyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.x4TX-h0NWa7D7yAZ4w1NXB8zg1TPIfXSvWdDzMTUL9Q','2026-05-11 09:04:44.116211','2026-05-18 09:04:44',7,'26bb440ffb5b4a6d8f1dc8659b2b3f9c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (97,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTEwNCwiaWF0IjoxNzc4NDkwMzA0LCJqdGkiOiI0NTcxMjBjMjYxM2I0Nzk3OGFkOWU3MjVjMzgwMDY2MyIsInVzZXJfaWQiOiI4In0.gryDHZcQoJhCkjGuUgW5KyMuGKuH6uY1rLUykDk5M1U','2026-05-11 09:05:04.805251','2026-05-18 09:05:04',8,'457120c2613b47978ad9e725c3800663');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (98,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTExMSwiaWF0IjoxNzc4NDkwMzExLCJqdGkiOiJjODM4OTM4Y2NhMzY0NDY0OTQzM2ExNDM5OTA2NTYxYiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.0shMtJO0vslI8xJ2rlUeplbPRK40wV6Bm2nAs9AwkXE','2026-05-11 09:05:11.498828','2026-05-18 09:05:11',8,'c838938cca3644649433a1439906561b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (99,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTM2NiwiaWF0IjoxNzc4NDkwNTY2LCJqdGkiOiI5N2Q3ZGUyODIzM2U0ZWU5ODU0OTkwYmYwYWExOWI2YSIsInVzZXJfaWQiOiI2In0.SBTlhiv7payKf84sGTqgyIiWQuNzusb1YdUa865SibQ','2026-05-11 09:09:26.685116','2026-05-18 09:09:26',6,'97d7de28233e4ee9854990bf0aa19b6a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (100,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTM3MiwiaWF0IjoxNzc4NDkwNTcyLCJqdGkiOiI4ZjRkYjlkOGJjMmI0MmQ2OGQ5Mzg1M2JlMTkyNWFjMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.UBjqk2obqE6vRDz00MWyxft7FdGviJM8-lKpvcXfDoU','2026-05-11 09:09:32.736739','2026-05-18 09:09:32',6,'8f4db9d8bc2b42d68d93853be1925ac0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (101,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTQ0NiwiaWF0IjoxNzc4NDkwNjQ2LCJqdGkiOiIyNWRlMGE0ODk3MmQ0NDM3OGNhNmJkZjhmYTg4ODJhMSIsInVzZXJfaWQiOiI2In0.PkGfAVT3RNESU3CNOa1c9e5WLoEmD4R-qUgwe0IHEuk','2026-05-11 09:10:46.815950','2026-05-18 09:10:46',6,'25de0a48972d44378ca6bdf8fa8882a1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (102,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NTgwMiwiaWF0IjoxNzc4NDkxMDAyLCJqdGkiOiJiOGEyZGM3MThkMzc0NDQ2YThkNmZlYjE3YTFiYmVjZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.YhUIdz1FZBNNb-DXEFDJDfYKTEyIvhGM-fbyhwiidQE','2026-05-11 09:16:42.763779','2026-05-18 09:16:42',6,'b8a2dc718d374446a8d6feb17a1bbecd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (103,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NjA4NywiaWF0IjoxNzc4NDkxMjg3LCJqdGkiOiJlMmYxM2E5NmQyNjc0ZTAyOTk0YTljN2E0MzBhZWI4NCIsInVzZXJfaWQiOiI2In0.7LtysGo_OvhdWCKDzPW9cgWFAgyEPIJCZ3OaMnKhva8','2026-05-11 09:21:27.620320','2026-05-18 09:21:27',6,'e2f13a96d2674e02994a9c7a430aeb84');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (104,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NjE3MCwiaWF0IjoxNzc4NDkxMzcwLCJqdGkiOiIzNDkwNDg1NTBjYjY0ODY2YThjZmQ5MzliYzA1ZTNmNSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.1eyEiVbGxjvIg8mZ1ndavNogaWmPlPN4pfZK6yPPUsA','2026-05-11 09:22:50.385887','2026-05-18 09:22:50',6,'349048550cb64866a8cfd939bc05e3f5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (105,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NjY5OSwiaWF0IjoxNzc4NDkxODk5LCJqdGkiOiJmOWNkOTM4YjE4MmU0MzFiYTVkODk0ZmYxY2NiNzM0MyIsInVzZXJfaWQiOiI2In0.QhrLQOA6dzGgRGHLQDynMKYVuOmJL_LFOZTiOiPvdMU','2026-05-11 09:31:39.233869','2026-05-18 09:31:39',6,'f9cd938b182e431ba5d894ff1ccb7343');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (106,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5Njc5OSwiaWF0IjoxNzc4NDkxOTk5LCJqdGkiOiJmOTU0MGMwNDBiY2Q0ODVlODk2NmE1ZmE3NDBiMWI2NiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.R1IZTqpImnaD8uuNvVj-9uzlFx7PclUZcZEe6IeD4M0','2026-05-11 09:33:19.357381','2026-05-18 09:33:19',6,'f9540c040bcd485e8966a5fa740b1b66');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (107,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NjkxNiwiaWF0IjoxNzc4NDkyMTE2LCJqdGkiOiI0N2IxMGQzYzZjZmI0YzQ2YTlkYTk3NGNmZDk5YzZiMyIsInVzZXJfaWQiOiI2In0.jzGAbmjGHF8kKs54Arr0OWbSvZDHQ5kCrJt1fdTWpgc','2026-05-11 09:35:16.004450','2026-05-18 09:35:16',6,'47b10d3c6cfb4c46a9da974cfd99c6b3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (108,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5Njk1MywiaWF0IjoxNzc4NDkyMTUzLCJqdGkiOiIwZDg1NjA5ZjgzNmE0OTc4YjU4NGQ3NGFiODg2NjNlNSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.zw2kR-W4VotEvR0W_bwVGarhEtILbxReInrYiGY0ivc','2026-05-11 09:35:53.336485','2026-05-18 09:35:53',6,'0d85609f836a4978b584d74ab88663e5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (109,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NzI0NCwiaWF0IjoxNzc4NDkyNDQ0LCJqdGkiOiJmN2NmZWQxZWJkNzY0YmYxOWMwMGEyNDE4NzFlZGVkNiIsInVzZXJfaWQiOiI2In0.vprUZeG76dTvcbzLvN0sWZZm2EMgXi1jXxf9HrSKoXU','2026-05-11 09:40:44.533581','2026-05-18 09:40:44',6,'f7cfed1ebd764bf19c00a241871eded6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (110,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NzQzMSwiaWF0IjoxNzc4NDkyNjMxLCJqdGkiOiJjNjhmYTViYjFhYWQ0MDBjYjViZmJlYjYzNDY5NGQ0YSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.ZDq69e4BAyP0zM0Iuibr-0RPQjEUMHSfkjIxW-7Ryc0','2026-05-11 09:43:51.825370','2026-05-18 09:43:51',6,'c68fa5bb1aad400cb5bfbeb634694d4a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (111,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTA5NzQzMSwiaWF0IjoxNzc4NDkyNjMxLCJqdGkiOiI0MjYwZWMwMGQ4NDY0ZTk1YWNiM2UzY2RmOTI2NDcxMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.TjY4mJF1RlcwUjiSbdfLue2FBCelEdCLi_OQnyfR_dQ','2026-05-11 09:43:51.836304','2026-05-18 09:43:51',6,'4260ec00d8464e95acb3e3cdf9264710');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (112,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNDgzNSwiaWF0IjoxNzc4NTAwMDM1LCJqdGkiOiI4NGJlMDZkZDg2YTM0OTMyOWY0ZWU4NmZjM2ZkZTIyNiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.kQwPEDzcbdYGTLexqplswJhDa3pbJeTK-93FydXGlkk','2026-05-11 11:47:15.920472','2026-05-18 11:47:15',6,'84be06dd86a349329f4ee86fc3fde226');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (113,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNDgzNSwiaWF0IjoxNzc4NTAwMDM1LCJqdGkiOiJkODIwYWFmYjViZDU0MGMzOGI2M2U1NDE0Yzk2NzU3NCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.ZfH-JnRzVycTygtzsEUfz3pGLeAv9jVgy6EjmEgfBqE','2026-05-11 11:47:15.932000','2026-05-18 11:47:15',6,'d820aafb5bd540c38b63e5414c967574');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (114,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjE0NCwiaWF0IjoxNzc4NTAxMzQ0LCJqdGkiOiJiNTRmM2RmNDc1OGE0NDk1OTM0ZWM5OTcwMzhhZTcyMCIsInVzZXJfaWQiOiI2In0.5eeOIcpavlGanYQ8kiQPFLhdFVJK5CzJFGKebfte3K4','2026-05-11 12:09:04.459542','2026-05-18 12:09:04',6,'b54f3df4758a4495934ec997038ae720');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (115,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjM4OSwiaWF0IjoxNzc4NTAxNTg5LCJqdGkiOiIzNzgxZWY3MjFmNDI0MDU4YmYxNjhhOTEwYThhNWE4MiIsInVzZXJfaWQiOiI4In0.uEQX8gTG94q6JExwSsHlZAsz4AeayFWqQk8wDMvEjBY','2026-05-11 12:13:09.878216','2026-05-18 12:13:09',8,'3781ef721f424058bf168a910a8a5a82');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (116,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjQ0NiwiaWF0IjoxNzc4NTAxNjQ2LCJqdGkiOiJmOWZmMmI5ZTQzMmY0MTIxOWQ1Y2QxNmM3MTZhMTQzMSIsInVzZXJfaWQiOiI2In0.OmaUSEMMN6qYDk-BYmx_WE1Ruf6LLE6mSkfz22MpEZo','2026-05-11 12:14:06.943706','2026-05-18 12:14:06',6,'f9ff2b9e432f41219d5cd16c716a1431');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (117,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjYyMiwiaWF0IjoxNzc4NTAxODIyLCJqdGkiOiIyNWYyNTE2NGUxOGI0NWVhOTAzM2I1M2QwOTAxZWQzNiIsInVzZXJfaWQiOiI3In0.0yCzCcujuefDT_BQSXlny8QWD0iQs8Er_YwpT4zm3g8','2026-05-11 12:17:02.318015','2026-05-18 12:17:02',7,'25f25164e18b45ea9033b53d0901ed36');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (118,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjcwNCwiaWF0IjoxNzc4NTAxOTA0LCJqdGkiOiIxNDRhZTNmNWVlNzI0MjA1YjRiMDUxOTZlODg2MzRmMCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.kdmQOnCvXbpByhNZ1KUXM4-4vtXei-fxmG9YWMklzK0','2026-05-11 12:18:24.260467','2026-05-18 12:18:24',7,'144ae3f5ee724205b4b05196e88634f0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (119,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjcwNCwiaWF0IjoxNzc4NTAxOTA0LCJqdGkiOiJkYzBiOThlMWE4MzQ0NzU2YjY2NDA2NGFmODc3MDM4MCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.L7gEk94B-IfKW9DiljQsMhznmlv6DUkpoCTSafT9ELs','2026-05-11 12:18:24.253074','2026-05-18 12:18:24',7,'dc0b98e1a8344756b664064af8770380');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (120,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjc3OSwiaWF0IjoxNzc4NTAxOTc5LCJqdGkiOiJhMWY1NmNlNmVhZjk0N2JiYmJjZjUzMWNhNmE4OTcyMSIsInVzZXJfaWQiOiI4In0.WJMO6VlhcgFOPNc7_Iy5JIdPSKbBQ14Klo-urqsQ33g','2026-05-11 12:19:39.448022','2026-05-18 12:19:39',8,'a1f56ce6eaf947bbbbcf531ca6a89721');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (121,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNjk1NywiaWF0IjoxNzc4NTAyMTU3LCJqdGkiOiIwMGNlZmVkM2YyODM0YmYwOGM3NTEwZDU2ZTk3NWFjNCIsInVzZXJfaWQiOiI2In0.6cKMGLk74irLOM7o5CfZaqYla4W8QWu4R67vqrfJGcw','2026-05-11 12:22:37.159718','2026-05-18 12:22:37',6,'00cefed3f2834bf08c7510d56e975ac4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (122,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNzM1NiwiaWF0IjoxNzc4NTAyNTU2LCJqdGkiOiIwZWVkMjAyNjgwMmI0ZmMxYTYxMjA2ZmVkMWZhNjg4OCIsInVzZXJfaWQiOiI2In0.DykDDcQd8T42cD3ju3tZiv9-YgIwH1fGx__FtGLVn1g','2026-05-11 12:29:16.241347','2026-05-18 12:29:16',6,'0eed2026802b4fc1a61206fed1fa6888');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (123,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNzM2NywiaWF0IjoxNzc4NTAyNTY3LCJqdGkiOiJjYzM4YzA5ZGM1ZTk0ODdhODY3MWVjYWM5NzZmZGU1OSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.1XU96LjWbI5AVxaItASmMQWSDndLlDoLV_Oqd90u2gM','2026-05-11 12:29:27.006920','2026-05-18 12:29:27',6,'cc38c09dc5e9487a8671ecac976fde59');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (124,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwNzM2NiwiaWF0IjoxNzc4NTAyNTY2LCJqdGkiOiI0N2ZjMzc4OWNmMjc0MDUwYmI5N2EyODZhM2Y5MmE1YyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0._ZSWunEcmoaC7dMaE1SsTjgRUgwnXLfhZqP4wxxhx6E','2026-05-11 12:29:26.982673','2026-05-18 12:29:26',6,'47fc3789cf274050bb97a286a3f92a5c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (125,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTAwMTE0NywiaWF0IjoxNzc4Mzk2MzQ3LCJqdGkiOiI1NjcxYTI3NmM5M2U0MWQxOGRjYmIzYTE4NDk2ZmU0NyIsInVzZXJfaWQiOiIyIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.HtvIyhIuLohHW6KcFMDlmx8L1IiOm_FZ5XpJPnaQrDI','2026-05-11 13:01:02.636037','2026-05-17 06:59:07',2,'5671a276c93e41d18dcbb3a18496fe47');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (127,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTI2MiwiaWF0IjoxNzc4NTA0NDYyLCJqdGkiOiJhNjg2OWMwYTc3MjE0ZjNlOWI1OTllMzQ5MjM3YjkxYSIsInVzZXJfaWQiOiIyIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.9xQsb2K_ZystYKYxRhf_ecnJ_KURw3llI_sZUQfiros','2026-05-11 13:01:02.636037','2026-05-18 13:01:02',2,'a6869c0a77214f3e9b599e349237b91a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (128,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTI2MiwiaWF0IjoxNzc4NTA0NDYyLCJqdGkiOiI4NzhlNTBkM2RhYzI0NTBjYjgzMWUyMTIyNTA5NjU3NyIsInVzZXJfaWQiOiIyIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.xyVJr9GoD-e-i5iqC9eDokII3eLTP-H1fTWwLOp3i-M','2026-05-11 13:01:02.628381','2026-05-18 13:01:02',2,'878e50d3dac2450cb831e21225096577');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (129,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTM3NiwiaWF0IjoxNzc4NTA0NTc2LCJqdGkiOiIzMTY5YTg4MDI5NTQ0YTc4YmE2YTI4YjkyNTdkN2IyZSIsInVzZXJfaWQiOiI3In0.BTaFFbGdH7B6f2dR0vjXZsQ5hWWYGBBlq_uKJZhUpSw','2026-05-11 13:02:56.854865','2026-05-18 13:02:56',7,'3169a88029544a78ba6a28b9257d7b2e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (130,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTQ0OCwiaWF0IjoxNzc4NTA0NjQ4LCJqdGkiOiJkY2U3NTY2MzBjYWQ0MjYwODY5MTA2ZDdhNjJkZTg4NCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.htvHRpfr1Yq2FaYB5icg9YB_VOc8Jdz6CM0S7y5E76I','2026-05-11 13:04:08.315042','2026-05-18 13:04:08',7,'dce756630cad4260869106d7a62de884');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (131,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTQ0OCwiaWF0IjoxNzc4NTA0NjQ4LCJqdGkiOiI2MzI3MTYxMTVjOTA0YzM0OGRmNmFhODM1Y2ZjODE4YyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.wTEamrbLIppFKm2Ha91QumTgOZsX4TYPWSNQYH6brR8','2026-05-11 13:04:08.365904','2026-05-18 13:04:08',7,'632716115c904c348df6aa835cfc818c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (132,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTQ5OCwiaWF0IjoxNzc4NTA0Njk4LCJqdGkiOiI2ODJkOGM5ODc5ODc0ZmU5OWE3NjU0YmNmODc2MzA2YyIsInVzZXJfaWQiOiI2In0.TgUsZUFaSvjZadZoeysq6N5HvxN3n-jfisSikRKUqLM','2026-05-11 13:04:58.225264','2026-05-18 13:04:58',6,'682d8c9879874fe99a7654bcf876306c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (133,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTUzMSwiaWF0IjoxNzc4NTA0NzMxLCJqdGkiOiI5YjVmYjI5M2Y4ZmQ0ZjdiOWFmMjUzNDY2YzQ5NDZlMiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.F8llxk-nvcf8jwV764iL6YzIY51w0kB1IT07-65nFyE','2026-05-11 13:05:31.198488','2026-05-18 13:05:31',7,'9b5fb293f8fd4f7b9af253466c4946e2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (134,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTUzMSwiaWF0IjoxNzc4NTA0NzMxLCJqdGkiOiIyMjUxMWYxY2RlODA0ODU0YjE0MTQ4NDY4YTJhYmI4NSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.Rj7rK0rEzHoKBB3kRTlv2m3iOPzOoantjQonEBnQTyc','2026-05-11 13:05:31.181504','2026-05-18 13:05:31',7,'22511f1cde804854b14148468a2abb85');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (135,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTYxNywiaWF0IjoxNzc4NTA0ODE3LCJqdGkiOiIyZmEzY2U4ODM2YmY0ZDI4ODljYTZhODU0YjFiZjgwYyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.HZg_EWXU26tT1f_khod2OwAPVAoCqCHlwLwq4M7xU6o','2026-05-11 13:06:57.603309','2026-05-18 13:06:57',7,'2fa3ce8836bf4d2889ca6a854b1bf80c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (136,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEwOTYxNywiaWF0IjoxNzc4NTA0ODE3LCJqdGkiOiI5YzNjZWFjZTM2MDc0ZTNjOWFmOWIwYTU2MzQ2MTZiZSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.vFJBf8erjP2Ob0jsRJGboUdBEg0tBZjUxnJ4CUzHS60','2026-05-11 13:06:57.619770','2026-05-18 13:06:57',7,'9c3ceace36074e3c9af9b0a5634616be');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (137,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExMDk5OSwiaWF0IjoxNzc4NTA2MTk5LCJqdGkiOiI4YjY3ZTM0Nzk3MWQ0YWIxODhjZTBmYjlkZDZiMzliOCIsInVzZXJfaWQiOiI2In0.GpDO5ez4TBuhn9kPmmxYos445puOcAfaUkOpAol5deI','2026-05-11 13:29:59.248723','2026-05-18 13:29:59',6,'8b67e347971d4ab188ce0fb9dd6b39b8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (138,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNDY5MiwiaWF0IjoxNzc4NTA5ODkyLCJqdGkiOiIzZmZkZmJkM2Q5MTg0MzJhYWY0ZTBjOGE0ZGJlNjk2ZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.E4HISd34YHqVhF0xPEIz9elkIbRGzGZxBhQlifdh2Ac','2026-05-11 14:31:32.106854','2026-05-18 14:31:32',6,'3ffdfbd3d918432aaf4e0c8a4dbe696d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (139,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNDY5MiwiaWF0IjoxNzc4NTA5ODkyLCJqdGkiOiIzNmIyMWNlYTYwZjI0MTM1OTIyOGI1MTkxZjJmZjRjNCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.wC8y6PZWLVpzpGy9Vqlab8AvFBVJu6Xmf-aIqTe3dy8','2026-05-11 14:31:32.103711','2026-05-18 14:31:32',6,'36b21cea60f241359228b5191f2ff4c4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (140,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNDgwOCwiaWF0IjoxNzc4NTEwMDA4LCJqdGkiOiJhZmFlNjU5NjMwMjY0YzA5OTQ2NWJlMjc5MTU4Y2ZiMyIsInVzZXJfaWQiOiI2In0.1COD9dDk7gIQ7ATHoavqxT3uMsj0T45_TqrsQrvzq4s','2026-05-11 14:33:28.144134','2026-05-18 14:33:28',6,'afae659630264c099465be279158cfb3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (141,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNDgwOSwiaWF0IjoxNzc4NTEwMDA5LCJqdGkiOiI0ZTE0MjQ2ODNkOTY0MGQzOWY1Y2E5YmQzZGQzZDQ5ZiIsInVzZXJfaWQiOiI2In0.LYWQErbV7fOuXKb0FJuynpZH3K7fVWC7pvvIiLSdMTE','2026-05-11 14:33:29.101836','2026-05-18 14:33:29',6,'4e1424683d9640d39f5ca9bd3dd3d49f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (142,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTA1NCwiaWF0IjoxNzc4NTEwMjU0LCJqdGkiOiI0OGQ2ZDkwMTc3ZDI0NDk3OTZhZTJlYmYzZTY1OTlmZSIsInVzZXJfaWQiOiI4In0.pwbq2rObr0fovIMnPKdjw2gytfQQSZAiUCQdFYT9I7c','2026-05-11 14:37:34.167804','2026-05-18 14:37:34',8,'48d6d90177d2449796ae2ebf3e6599fe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (143,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTA4MSwiaWF0IjoxNzc4NTEwMjgxLCJqdGkiOiJhNTI3NjllMWE2ZWU0NDAwYmFkNjJiZjk3ZWU4ZmMzNCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.qeMbCP32ruHIyKfx2z-EeZDYRHLkXJ1F8Ymt7zTaZ0g','2026-05-11 14:38:01.226085','2026-05-18 14:38:01',8,'a52769e1a6ee4400bad62bf97ee8fc34');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (144,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTA4MSwiaWF0IjoxNzc4NTEwMjgxLCJqdGkiOiIzMDNjZTMxZTcwNTM0NzRiYTNhYjU3MzlkYjRkNDFjZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.JXXKZOQgLr8UrU8yf5D8cOdIevpcE32hTsLAPB7oi-c','2026-05-11 14:38:01.239427','2026-05-18 14:38:01',8,'303ce31e7053474ba3ab5739db4d41cf');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (145,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTIyMCwiaWF0IjoxNzc4NTEwNDIwLCJqdGkiOiI5MDk2NjU1NzMwZjY0YTM0YjNiOTkxOWI5Y2U3ZGFjYSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.ueK8-jYfMBdVW0KXh2ZYikrFVdVX11Kch3qZC2WtS4k','2026-05-11 14:40:20.986548','2026-05-18 14:40:20',8,'9096655730f64a34b3b9919b9ce7daca');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (146,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTIyMCwiaWF0IjoxNzc4NTEwNDIwLCJqdGkiOiI0ZTdkODJhMzk5MmM0ZWVmODM4Y2MzMjc0YTY4ZjY4OCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.71y7IdmYwMT4Enke8pHPoSN_dCQ_Mhs4RO0Q7Pn78p0','2026-05-11 14:40:20.963133','2026-05-18 14:40:20',8,'4e7d82a3992c4eef838cc3274a68f688');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (147,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTMzMywiaWF0IjoxNzc4NTEwNTMzLCJqdGkiOiIzZjFiMTQyOGZhZmM0ZWQwYjZlYmMwYTRlOTdlYWI4YSIsInVzZXJfaWQiOiI2In0.GGW2VikgHrflGfCJb0eN2MrWOZUszdKJkccoOppSsow','2026-05-11 14:42:13.602211','2026-05-18 14:42:13',6,'3f1b1428fafc4ed0b6ebc0a4e97eab8a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (148,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTExNTU1MCwiaWF0IjoxNzc4NTEwNzUwLCJqdGkiOiJjOGE4ZDk2NWZjOGY0OTFjYjFhODA4OTcxMDY4NzZlYSIsInVzZXJfaWQiOiI3In0.OoVfw9Xj1WUK0jMqWoN_d0_c6KmaRJ-MwYpelsFeTL4','2026-05-11 14:45:50.286776','2026-05-18 14:45:50',7,'c8a8d965fc8f491cb1a80897106876ea');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (149,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMTk3NCwiaWF0IjoxNzc4NTE3MTc0LCJqdGkiOiIzZDQ4ZTRjZGJhNjg0MmUzOTAzZmVjNjIzNjFlMDlmMiIsInVzZXJfaWQiOiI2In0.s4skI2pAcZ_bsxu-x62HbvkwYVSOIzsnLAnMKEgfbsM','2026-05-11 16:32:54.235830','2026-05-18 16:32:54',6,'3d48e4cdba6842e3903fec62361e09f2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (150,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzE3NiwiaWF0IjoxNzc4NTE4Mzc2LCJqdGkiOiIxOTczY2I2YTY5Mjk0YWZhOTkzMTVmOWI3NDBjNWY3ZSIsInVzZXJfaWQiOiI3In0.Tx2BzUf0ndqPLDX8qfNCI8AozO_69ltJZDu3yaeuXpM','2026-05-11 16:52:56.910137','2026-05-18 16:52:56',7,'1973cb6a69294afa99315f9b740c5f7e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (151,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzE5NiwiaWF0IjoxNzc4NTE4Mzk2LCJqdGkiOiI2MjExNThjYTRjYzg0MjcxYjM2OTFlMzZmYzgwZTMwYiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.Gl61D_oEADAvccAqTXnPAAQVUbZuHXhsKXxhvzCrIlI','2026-05-11 16:53:16.234499','2026-05-18 16:53:16',7,'621158ca4cc84271b3691e36fc80e30b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (152,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzE5NiwiaWF0IjoxNzc4NTE4Mzk2LCJqdGkiOiJlMzY4ZWMyNjgxYjM0ZjFlOGVhYzhhMGQ1Yjc3ZTNkOCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.-hVCzip98uwF3EMWXqYThTp4JsEs0aJc5wZhBld7dio','2026-05-11 16:53:16.240563','2026-05-18 16:53:16',7,'e368ec2681b34f1e8eac8a0d5b77e3d8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (153,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzc0MCwiaWF0IjoxNzc4NTE4OTQwLCJqdGkiOiIyMTI4NzIzY2IwYzQ0NTU1OGJjYzYxM2ZhNzE1OWEyYyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.SijOdoVELLhs_Qx7UrifZckraSIMtH6P8FlbW40XEwI','2026-05-11 17:02:20.801368','2026-05-18 17:02:20',7,'2128723cb0c445558bcc613fa7159a2c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (154,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzc0MCwiaWF0IjoxNzc4NTE4OTQwLCJqdGkiOiJhNWJiNzczYTIzM2E0ODkwOTcwNTk5ZTBlNTYxZTBjMCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.rFJfzRiOH7ggpM-9m7RMwpIawC2OgerLH-OkbDI_A1A','2026-05-11 17:02:20.798504','2026-05-18 17:02:20',7,'a5bb773a233a4890970599e0e561e0c0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (155,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzc5NSwiaWF0IjoxNzc4NTE4OTk1LCJqdGkiOiJiZmJkOTY0ZWFlMDY0MDE5OTUxMmJmNzllZDUxMDVhMSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.PDSx3kqXl62-BEU1LFe8jlbo_9D7KX2y7mZOzAcBfMM','2026-05-11 17:03:15.660031','2026-05-18 17:03:15',7,'bfbd964eae0640199512bf79ed5105a1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (156,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzc5NSwiaWF0IjoxNzc4NTE4OTk1LCJqdGkiOiJhYTRiMjAxNzBhN2U0MjllODFhOGU3NjJhNTNiY2FlNyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.E-MxZXW5z-nY9eWbuYxRZSVDagq81BBDKLf2uq_mROE','2026-05-11 17:03:15.654330','2026-05-18 17:03:15',7,'aa4b20170a7e429e81a8e762a53bcae7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (157,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzgzMCwiaWF0IjoxNzc4NTE5MDMwLCJqdGkiOiJlZmU0ZWFmYTA1NDM0MTdkYjc4NGMyZjk2MDkyZTYwMSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.e5F-RmXQTtkwr7pyzF1MEriz0nPCTAChhrlNBl0BBmg','2026-05-11 17:03:50.154158','2026-05-18 17:03:50',7,'efe4eafa0543417db784c2f96092e601');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (158,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzgzMCwiaWF0IjoxNzc4NTE5MDMwLCJqdGkiOiIyYTY0ZWU2YTVlMzU0MGFjYjUxYmY1NDY0ZDA1NDJiMCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.7iG3SCdS_VZrfuscajak5YQzX7rrTqJS3oeLJfYUPyU','2026-05-11 17:03:50.168850','2026-05-18 17:03:50',7,'2a64ee6a5e3540acb51bf5464d0542b0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (159,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzkxOCwiaWF0IjoxNzc4NTE5MTE4LCJqdGkiOiIxYjVhZjgxOGFjMjc0NjM0YmE1YTA1Mjg5YTZlNWRkYyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.e4uZz8DdFSubm3VAT5DNcjDOwme4z_Uh2AdJxdynzc4','2026-05-11 17:05:18.413064','2026-05-18 17:05:18',7,'1b5af818ac274634ba5a05289a6e5ddc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (160,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzkxOCwiaWF0IjoxNzc4NTE5MTE4LCJqdGkiOiIwOGNhOTU4YzdlODg0MzMyYmIwNGFlYzdkOGZkZmIwYyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.aWo7d-O2Sr42b6eBgBbbCy8Kxf3touKcEzGEMtW0Abc','2026-05-11 17:05:18.443629','2026-05-18 17:05:18',7,'08ca958c7e884332bb04aec7d8fdfb0c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (161,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzkyNSwiaWF0IjoxNzc4NTE5MTI1LCJqdGkiOiI5MTU0NDEzOWE5MmY0YTIyOWJiZTU5MzJhZGZlY2FmMiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.ZfR8uEOql5uFIovghfoxIO9b4xMpEdGL_2VWT70kNK0','2026-05-11 17:05:25.973475','2026-05-18 17:05:25',7,'91544139a92f4a229bbe5932adfecaf2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (162,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyMzkyNSwiaWF0IjoxNzc4NTE5MTI1LCJqdGkiOiI2YzFhYzhkMzk0Y2Q0NzhmOTA2ZWY2NWNiZGNjNGZjMSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.5puL3OF2Sg3QJKcGXHqHrs5puXd3FBy_lrOSfUWvEx4','2026-05-11 17:05:25.982702','2026-05-18 17:05:25',7,'6c1ac8d394cd478f906ef65cbdcc4fc1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (163,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNDc0OSwiaWF0IjoxNzc4NTE5OTQ5LCJqdGkiOiI1MzNlNzM1OTFkOGY0NmJhYmI1YTA1MWI2ODQ1ZWQ4OCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.dek7KFBcxx-85Zt4Skdpn3DzCbZseGfY4jqJT7ap1m4','2026-05-11 17:19:09.589924','2026-05-18 17:19:09',7,'533e73591d8f46babb5a051b6845ed88');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (164,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNDc0OSwiaWF0IjoxNzc4NTE5OTQ5LCJqdGkiOiIyYTQxN2FiYzk3YTU0MjViYTI4N2UyZTM1NDNiYzVmYyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.roF3-V9MiUlJgEyU7tP41X27U8iQ_ZS705hxxKKacJM','2026-05-11 17:19:09.604488','2026-05-18 17:19:09',7,'2a417abc97a5425ba287e2e3543bc5fc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (165,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNTc4MiwiaWF0IjoxNzc4NTIwOTgyLCJqdGkiOiJiMDI5ZWM5ZWFjZGM0OTAzYjI4MTc2MjhhMmMwY2NmZSIsInVzZXJfaWQiOiI2In0.KNWO6-166aSEdI9vA_hEaX_C3bYut7LPQ6M6efSDazk','2026-05-11 17:36:22.423068','2026-05-18 17:36:22',6,'b029ec9eacdc4903b2817628a2c0ccfe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (166,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNTkzNCwiaWF0IjoxNzc4NTIxMTM0LCJqdGkiOiI1NjEyYjEwNjcxMGY0ZmMxYmZhZmI2ZTI2YzVlYmY3NyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.uVrKXNP_ewojOHWvTB_Kwfu9cQmqxraqfTeRWSlInhQ','2026-05-11 17:38:54.459188','2026-05-18 17:38:54',6,'5612b106710f4fc1bfafb6e26c5ebf77');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (167,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNTkzNCwiaWF0IjoxNzc4NTIxMTM0LCJqdGkiOiJhYmNjZGFkNmU2NDI0MWU2YTEzNDhkMmJkNjQ1NmUxZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.TmBzGEZAfir_R-gafKTBq0YJoO2AwjOji-gpxO0Ip64','2026-05-11 17:38:54.452670','2026-05-18 17:38:54',6,'abccdad6e64241e6a1348d2bd6456e1d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (168,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNTk1NCwiaWF0IjoxNzc4NTIxMTU0LCJqdGkiOiI3ZDk1MTFjZDEzMjU0MmJkYTQzMTMyYjQ5OTAyZDMyZSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.BPWhuV-fk7HWzM2YKNHrGSDNrII0FcEHkVHcS3Tq0x8','2026-05-11 17:39:14.966519','2026-05-18 17:39:14',6,'7d9511cd132542bda43132b49902d32e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (169,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNTk1NCwiaWF0IjoxNzc4NTIxMTU0LCJqdGkiOiJhOWU5ZDkwMWRhNmY0MzFjYjM3NzdmODU2OGU4ODcwYiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.n8a3_x6_mRXfHJRKJtnd6MJ44FFAdRYua958KdJU8EA','2026-05-11 17:39:14.976214','2026-05-18 17:39:14',6,'a9e9d901da6f431cb3777f8568e8870b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (170,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjA0NSwiaWF0IjoxNzc4NTIxMjQ1LCJqdGkiOiI4ODUzNjFhZTQzNGQ0NGE4OTA2OThjNWU0MmEwYTA3MCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.HTa0oUse8xg6_-3eYxiSOpPXcjE5L9Iqwjxs4QsKpeE','2026-05-11 17:40:45.434095','2026-05-18 17:40:45',6,'885361ae434d44a890698c5e42a0a070');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (171,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjA0NSwiaWF0IjoxNzc4NTIxMjQ1LCJqdGkiOiJlZjUyZDE2MzY1MjU0ZWQ3OWRiYjg3NmY0OWQ5ODk1OSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.pu_6zVI8BefNNOJSGOXOtgPcIbO5vx5gKdVbOxSYQLk','2026-05-11 17:40:45.440464','2026-05-18 17:40:45',6,'ef52d16365254ed79dbb876f49d98959');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (172,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjA3NSwiaWF0IjoxNzc4NTIxMjc1LCJqdGkiOiJmZGNhOWE0ZGJkMjg0MWJkYWI0NWQ0YTZkYjJiYTNmNSIsInVzZXJfaWQiOiI3In0.f06Kq6YJPuETzaJIWpSOjwUg5pjpzNMdTWyShm20q1w','2026-05-11 17:41:15.968911','2026-05-18 17:41:15',7,'fdca9a4dbd2841bdab45d4a6db2ba3f5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (173,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjEwNiwiaWF0IjoxNzc4NTIxMzA2LCJqdGkiOiJiMTc5Y2UwNTU0ODI0MmRhOTdiMmU1MTU2YzQ5NDNmNiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.vZ1YyA3CKFsiJBJOMhNKQlaJs2XbgWOoOSUyE2yRBjo','2026-05-11 17:41:46.746217','2026-05-18 17:41:46',7,'b179ce05548242da97b2e5156c4943f6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (174,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjEwNiwiaWF0IjoxNzc4NTIxMzA2LCJqdGkiOiJlZDFiYTE3MmQ4NzQ0OThmYWZiYjVjYzQ3ZjY1M2VlYiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.AVRZSB8xl3_IJnI2Vm7bVqVCyLyr3YVNdkcYgAXSmQk','2026-05-11 17:41:46.822265','2026-05-18 17:41:46',7,'ed1ba172d874498fafbb5cc47f653eeb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (175,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjE2MywiaWF0IjoxNzc4NTIxMzYzLCJqdGkiOiJjNTFjMzJhMjg3ZDQ0ODNhOTViNzhjYzE0NjE5M2U4ZSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.8dLKkhrIDQmbvC6ddQjOE5alkRs9GrSaqw9vqTxjrh0','2026-05-11 17:42:43.413440','2026-05-18 17:42:43',7,'c51c32a287d4483a95b78cc146193e8e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (176,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjE2MywiaWF0IjoxNzc4NTIxMzYzLCJqdGkiOiI5MDVkZmUxYzdkZjM0YWViODc0NDk2NjZjY2UxMTk3MSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.NGGg1H8s0g0yc31aI2l9gslO5SyYNMTbE-h63bl4LcE','2026-05-11 17:42:43.435788','2026-05-18 17:42:43',7,'905dfe1c7df34aeb87449666cce11971');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (177,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjE5MSwiaWF0IjoxNzc4NTIxMzkxLCJqdGkiOiI2ZGI2YTc2NWUwYjM0MDFlOTM2NjM5NGZiNGQ3NGRhMCIsInVzZXJfaWQiOiI2In0.J_5G71oTp1UQ87SFXPLId_sSNL3Tzj8rQRoIPDwM2No','2026-05-11 17:43:11.067473','2026-05-18 17:43:11',6,'6db6a765e0b3401e9366394fb4d74da0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (178,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjIzMCwiaWF0IjoxNzc4NTIxNDMwLCJqdGkiOiJmN2UwY2RhY2Q2YmI0MDJiYTE2MDdlZjllNWY1Mjk2ZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.4wKJi2HJ-2loJ8QWIqcrA3-JPuBbZYoohdnqCkbxdYo','2026-05-11 17:43:50.841037','2026-05-18 17:43:50',6,'f7e0cdacd6bb402ba1607ef9e5f5296d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (179,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjIzMCwiaWF0IjoxNzc4NTIxNDMwLCJqdGkiOiJiZTJmYTllMTU0ZmU0ODhlODU4NTZjYWQyNDkyMmVlMyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.QltYUatjhI-BlbCQSP0u6UVbr5POta69zCXfiEsY67E','2026-05-11 17:43:50.845628','2026-05-18 17:43:50',6,'be2fa9e154fe488e85856cad24922ee3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (180,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjQ3NiwiaWF0IjoxNzc4NTIxNjc2LCJqdGkiOiI2ODcxOTBhYWE3YzQ0NGEzODg3NjVmZjAyOWI1MTJjYSIsInVzZXJfaWQiOiI3In0.y81FuVMx2M93oSHARqU2eU3YxGEdcA3rysCrzxzPznE','2026-05-11 17:47:56.960972','2026-05-18 17:47:56',7,'687190aaa7c444a388765ff029b512ca');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (181,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjYyMywiaWF0IjoxNzc4NTIxODIzLCJqdGkiOiI3ODgzNjY3ZWExZjM0YzBhOWYwZjE2NGZmOWZkZWNhNyIsInVzZXJfaWQiOiI2In0.LBBlBBdUI9aXZ3vhFuf-C2uF6eT7p8jflhwd6Su_kEQ','2026-05-11 17:50:23.414262','2026-05-18 17:50:23',6,'7883667ea1f34c0a9f0f164ff9fdeca7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (182,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjY1MiwiaWF0IjoxNzc4NTIxODUyLCJqdGkiOiI4NDIzMTdhYjAzNWE0YTI5YTJkYTI4ZGFkZjFiOTZkOSIsInVzZXJfaWQiOiI3In0.yeYqI8gCuvevEfJ5giFznHfyY9mXW826t9fSXHXef3E','2026-05-11 17:50:52.785202','2026-05-18 17:50:52',7,'842317ab035a4a29a2da28dadf1b96d9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (183,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjcwMiwiaWF0IjoxNzc4NTIxOTAyLCJqdGkiOiIwY2E5N2IzNTlkMTQ0YzYzOWMyZjgwM2Y0NzdlNjQ4MSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.fGH_B1W6ki9RnEEluuVb5fbUKuD5FdgX97spp9GVP0g','2026-05-11 17:51:42.287587','2026-05-18 17:51:42',6,'0ca97b359d144c639c2f803f477e6481');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (184,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjcwMiwiaWF0IjoxNzc4NTIxOTAyLCJqdGkiOiIxMWVmOThkOTBkMzQ0YmJiODcxYWQ1ZmZlY2JhOTg4NSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.HATjfrRbEuFAb3he5aTH8NQCrg4zhQh_S4S7ZUnKl00','2026-05-11 17:51:42.285365','2026-05-18 17:51:42',6,'11ef98d90d344bbb871ad5ffecba9885');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (185,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjc1NiwiaWF0IjoxNzc4NTIxOTU2LCJqdGkiOiI3ZDc4OWU0NTE4N2Q0NGI3YWUyNjQ3YTFmMWNhZDNlZCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.UhW960tZTSHErUYlpwA08I0_f3OwJC_HjbMR6TESWLg','2026-05-11 17:52:36.416706','2026-05-18 17:52:36',7,'7d789e45187d44b7ae2647a1f1cad3ed');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (186,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjc1NiwiaWF0IjoxNzc4NTIxOTU2LCJqdGkiOiIwNDEyZDQ1NGRiOWQ0Njk5OTBkZWU1MTNmZGE5MmM3MSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.Yh98xFXhRGNuxuq1duU52lMsJLu2O4Nt4fkHRddFha0','2026-05-11 17:52:36.510192','2026-05-18 17:52:36',7,'0412d454db9d469990dee513fda92c71');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (187,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjc5MywiaWF0IjoxNzc4NTIxOTkzLCJqdGkiOiI4NjVjMzE0ZTA0OTI0MjM2OTMxZDdjNTg1OWM4ODFlMiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.mywE7tm1gSNLomWUW9DWf_kOHww6VDSqChF4ncE3cuI','2026-05-11 17:53:13.795668','2026-05-18 17:53:13',6,'865c314e04924236931d7c5859c881e2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (188,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNjc5MywiaWF0IjoxNzc4NTIxOTkzLCJqdGkiOiJmYTUwM2M3YTI1ZGU0YWFjOTc3YmM0NDlmOWE5ZjE5NyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.2Yq8caECDbqh2bz5vYFD94tNtuUiKcAPvjEj0hHzFbg','2026-05-11 17:53:13.799945','2026-05-18 17:53:13',6,'fa503c7a25de4aac977bc449f9a9f197');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (189,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzA5MSwiaWF0IjoxNzc4NTIyMjkxLCJqdGkiOiI2ZWU2MWM2NjU2YmE0NTMyYWExNGYxNjhhZjg1MTJkMSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.sVxVLJXBhH7gW-O0V_byrtwDcIHE4bRr4WdULL8xXh8','2026-05-11 17:58:11.125901','2026-05-18 17:58:11',6,'6ee61c6656ba4532aa14f168af8512d1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (190,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzA5MSwiaWF0IjoxNzc4NTIyMjkxLCJqdGkiOiJhNWNkMTY3NjYxZTg0YTAwOTBkNTYyMDdjM2UxYjg4NCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.9zXQx3jtvHW0pjZpeEOHepU3WX-bBL1BXu-XavQ5l8w','2026-05-11 17:58:11.120707','2026-05-18 17:58:11',6,'a5cd167661e84a0090d56207c3e1b884');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (191,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzI0NCwiaWF0IjoxNzc4NTIyNDQ0LCJqdGkiOiI0NWZjM2JkM2Q0Y2Q0NzVjOTE5OGE1YzFiN2UwNGNhYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.1PqA1FIwRLT0vKCQq5svoBMS9qSNaZ5m93aTv5kyeQ0','2026-05-11 18:00:44.245279','2026-05-18 18:00:44',6,'45fc3bd3d4cd475c9198a5c1b7e04caa');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (192,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzI0NCwiaWF0IjoxNzc4NTIyNDQ0LCJqdGkiOiIwMmM1MDkxNmQ4NjA0ZjJjYjk5ZTFhNmQ2OTQ3ODY1MiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.01dKWhvftU7ValnVtSAT_hCYEhWLLRROE1eq6DUgmVI','2026-05-11 18:00:44.240014','2026-05-18 18:00:44',6,'02c50916d8604f2cb99e1a6d69478652');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (193,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzYwNiwiaWF0IjoxNzc4NTIyODA2LCJqdGkiOiIzZjJjNGE3MzMzMDI0N2E5OTNlNDJkYzQ2YTk3ZDllMyIsInVzZXJfaWQiOiI4In0.8aFt0wiOOgfXDfXietLZuWMa3Z4-DSMe1xQagjefyN0','2026-05-11 18:06:46.707101','2026-05-18 18:06:46',8,'3f2c4a73330247a993e42dc46a97d9e3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (194,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzcxOCwiaWF0IjoxNzc4NTIyOTE4LCJqdGkiOiJiNzE5OTQzN2Q2ZDQ0Mjk2YWEzNTJiMDE5NzgyOGMwZSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.-xpYQFi_6jQ-u82NBtP72B61UXD3ULy47Xs2f8k8Cm8','2026-05-11 18:08:38.878437','2026-05-18 18:08:38',8,'b7199437d6d44296aa352b0197828c0e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (195,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzcxOCwiaWF0IjoxNzc4NTIyOTE4LCJqdGkiOiI1ZmUzZjIxMDExNTE0M2E3OGJmOTMzOWZiN2I3MDhmYiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.Iz0tz2bP3LHhw-s1SxHlUol1rrQ7ON9P5GE6aDLmJfk','2026-05-11 18:08:38.911508','2026-05-18 18:08:38',8,'5fe3f210115143a78bf9339fb7b708fb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (196,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzcyNSwiaWF0IjoxNzc4NTIyOTI1LCJqdGkiOiJlYjZjY2U0ZjM5MTI0M2M5YTMzYmVlNWMwNWRlOWY3YiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.L5mPMmgUn96mE1xV9Bap5_IOcIcuaK2sD4Af2a0kUT4','2026-05-11 18:08:45.528165','2026-05-18 18:08:45',7,'eb6cce4f391243c9a33bee5c05de9f7b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (197,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzcyNSwiaWF0IjoxNzc4NTIyOTI1LCJqdGkiOiI1OWEyYjJkZDNjN2Y0MTQ3YTNjNDc3MThlNjFhZDA3MiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.9CJtJwG_flNDaws3DEqLL49v9_tMyG-azrjAS_8ycmA','2026-05-11 18:08:45.490356','2026-05-18 18:08:45',7,'59a2b2dd3c7f4147a3c47718e61ad072');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (198,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTEyNzgyNywiaWF0IjoxNzc4NTIzMDI3LCJqdGkiOiI1ZTBhNjAxMzU4ZDE0MzVlYWEwZDBlYTI3YWJmYzJlZiIsInVzZXJfaWQiOiI2In0.Vhg6Zuck_b-wfauRzET_30HAcWYFxslECTty44XiKwg','2026-05-11 18:10:27.718679','2026-05-18 18:10:27',6,'5e0a601358d1435eaa0d0ea27abfc2ef');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (199,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE2NzI4OSwiaWF0IjoxNzc4NTYyNDg5LCJqdGkiOiI2YjU1YzViZjMwMzg0OGYxOGY1MTUwYjc3NDU0NDUxNyIsInVzZXJfaWQiOiI3In0.dVkKzakG9iYfrICBJiUwW4uoAtoBal_5I1Cq8OeXA3A','2026-05-12 05:08:09.799307','2026-05-19 05:08:09',7,'6b55c5bf303848f18f5150b774544517');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (200,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE2NzQ4NCwiaWF0IjoxNzc4NTYyNjg0LCJqdGkiOiI5NWJjNzQ4YzY0Y2E0MWJjYjAwOGZiMzQwZDVjZmFjNSIsInVzZXJfaWQiOiI2In0.0gEbmSk17lfwM4Kqy1pH9n_yL8AWeQHn8x3utTb8EdQ','2026-05-12 05:11:24.512095','2026-05-19 05:11:24',6,'95bc748c64ca41bcb008fb340d5cfac5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (201,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MDI3MywiaWF0IjoxNzc4NTY1NDczLCJqdGkiOiJjMjg5ZjM3YjBjNjI0YWMwOWVmMzExNWI0NzRkNDFlZCIsInVzZXJfaWQiOiI2In0.lItmgvTe7QALLTsEaoAXjdcXe0TpKo8JFnAmARNe9u4','2026-05-12 05:57:53.858522','2026-05-19 05:57:53',6,'c289f37b0c624ac09ef3115b474d41ed');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (202,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MDczMCwiaWF0IjoxNzc4NTY1OTMwLCJqdGkiOiIyYzU2Y2Y3YjI0OTk0MjQ4OGQ2MDJjNTRkNjIzNTRiNiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.wQFori6OJ85ICoAddHT2b2KFgL1hMLNVrbDRjqjK9cQ','2026-05-12 06:05:30.160388','2026-05-19 06:05:30',6,'2c56cf7b249942488d602c54d62354b6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (203,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MDczMCwiaWF0IjoxNzc4NTY1OTMwLCJqdGkiOiJlYzFiYjk2YTExNzc0ODhmYjE0NDdkNzJiYWNkNGVmOCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.tXYqNDzNFWreWOD5_kQipMqAVFiawLxU76fa0Skkgck','2026-05-12 06:05:30.157514','2026-05-19 06:05:30',6,'ec1bb96a1177488fb1447d72bacd4ef8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (204,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MDk3NywiaWF0IjoxNzc4NTY2MTc3LCJqdGkiOiJmMmFjODlmZDU3ZGM0OTdmOWViM2EwNGEzZWMzZTQxMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.6DwEi6VYrnQlptTmXyQa6KHZMW85qXjX0o6MZ8StcNU','2026-05-12 06:09:37.073249','2026-05-19 06:09:37',6,'f2ac89fd57dc497f9eb3a04a3ec3e410');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (205,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MDk3NywiaWF0IjoxNzc4NTY2MTc3LCJqdGkiOiJkYjAwMTg3ODZiN2I0Njc3Yjc3NjNkNTkzYTc2YTJiMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.MqPrIxxQpR35SE-6B-FgOlGeB2hHvkYD2ShiBXkKl90','2026-05-12 06:09:37.063792','2026-05-19 06:09:37',6,'db0018786b7b4677b7763d593a76a2b0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (206,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MTA1MSwiaWF0IjoxNzc4NTY2MjUxLCJqdGkiOiJmNTU3YjMzMjM2MzQ0ZDNkOWNiZDM5ODA0NWM2NTExZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.jiSc_HSAcdw5iPiAQXoMSDFJCqOsmFTYqhUl8rmzdwg','2026-05-12 06:10:51.279803','2026-05-19 06:10:51',6,'f557b33236344d3d9cbd398045c6511d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (207,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MTA1MSwiaWF0IjoxNzc4NTY2MjUxLCJqdGkiOiI2ZDczNTEzZTVlOWI0Yzc0ODhlNzdkM2QzMGMwMmE2NyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.vpi7h9JNUj6Z1u0aThXeotVwolt6FrS_YDHInif9GZs','2026-05-12 06:10:51.273334','2026-05-19 06:10:51',6,'6d73513e5e9b4c7488e77d3d30c02a67');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (208,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MTg4NCwiaWF0IjoxNzc4NTY3MDg0LCJqdGkiOiI4YmU0NWNhNDEzNTg0MmNmYTliOGEzM2ExOGU4MjljOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.SlwfFGqyHR-JwFn2MHNUG7XmavBcKV-DN8tQv7a1v_E','2026-05-12 06:24:44.626224','2026-05-19 06:24:44',6,'8be45ca4135842cfa9b8a33a18e829c9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (209,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MTg4NCwiaWF0IjoxNzc4NTY3MDg0LCJqdGkiOiJiOTRkNTI4N2FkZGQ0YmQzODYxYmZjM2E2MjMzNDg2NiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Bt9l-Ro8-qglcR247uLBFcozLhVL466XInmp0Iw9LCc','2026-05-12 06:24:44.629348','2026-05-19 06:24:44',6,'b94d5287addd4bd3861bfc3a62334866');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (210,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MjQ0MSwiaWF0IjoxNzc4NTY3NjQxLCJqdGkiOiJkZDIzMzdjNGU1Njc0ZWJkYjQwYjlhYmY3NGEwNmM5YiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.7LdCWjYBO_HHfgcY5ljTMQrq029gKt5rWKhtVJMPqXE','2026-05-12 06:34:01.976262','2026-05-19 06:34:01',6,'dd2337c4e5674ebdb40b9abf74a06c9b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (211,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MjQ0MSwiaWF0IjoxNzc4NTY3NjQxLCJqdGkiOiJkYzZlYzM3YzJjNDQ0ZTAyOWJmYzdiY2FkNjRmYjg1OCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.TQPScpDWop8PLzV7gbwyV2ZmSGMZzX4JS1aILM17FqI','2026-05-12 06:34:01.966741','2026-05-19 06:34:01',6,'dc6ec37c2c444e029bfc7bcad64fb858');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (212,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MjUyOSwiaWF0IjoxNzc4NTY3NzI5LCJqdGkiOiI0MjliYjFhOGNlYTU0MWZkOWQzNGFlZTViYzZjZjIyYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.FA_9wJJh3ie_sCNCKjPL_OtJtb9emyfWE50r9fZaAIA','2026-05-12 06:35:29.385749','2026-05-19 06:35:29',6,'429bb1a8cea541fd9d34aee5bc6cf22a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (213,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MjUyOSwiaWF0IjoxNzc4NTY3NzI5LCJqdGkiOiI5MjVhZjk4N2Y4Y2Q0ZDM3ODY0ODBiZDVmOGY0YWI4YSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.eJU-U-s-Xp2-q5u-IjaxU0BytIYDADt79GLUQoFwhWA','2026-05-12 06:35:29.400312','2026-05-19 06:35:29',6,'925af987f8cd4d3786480bd5f8f4ab8a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (214,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MjU1NiwiaWF0IjoxNzc4NTY3NzU2LCJqdGkiOiJjNWY4MDBlY2Q4ZTg0MTRhYjEyNzRlNGJkYjVhM2EzMyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Zxw86EalNVum4XBVYXwjdWtCZ8YrXtDwFS4DUH07NJM','2026-05-12 06:35:56.062691','2026-05-19 06:35:56',6,'c5f800ecd8e8414ab1274e4bdb5a3a33');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (215,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3MjU1NiwiaWF0IjoxNzc4NTY3NzU2LCJqdGkiOiI2YmQ1Yjk1NzI3ZmI0ZjFhYmUyYTRlN2I2NDVkNjA3MCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.2t2HtUXqIi3XSrI7MyzSvDKRbNWe3Gt-3TisTcOVcso','2026-05-12 06:35:56.071595','2026-05-19 06:35:56',6,'6bd5b95727fb4f1abe2a4e7b645d6070');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (216,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NDMxNSwiaWF0IjoxNzc4NTY5NTE1LCJqdGkiOiI1YzQzZTc5ZTllZmE0N2IzYjc2OTA2NmU4YjAyM2Q1NiIsInVzZXJfaWQiOiIxIn0.5aNDFn_JgS93g5twbXI3sa2i5IPOZ_XBrS65CR9RW88','2026-05-12 07:05:15.357018','2026-05-19 07:05:15',1,'5c43e79e9efa47b3b769066e8b023d56');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (217,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NDMyNCwiaWF0IjoxNzc4NTY5NTI0LCJqdGkiOiI5YzFjMTkyMjlmZmY0MjFjOWJhZjg5OGRkODliMGYyYyIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.u5AD-mS0vuc4zN_LWt__DNfOBfiSSijZVsJxPHcMmxQ','2026-05-12 07:05:24.757182','2026-05-19 07:05:24',1,'9c1c19229fff421c9baf898dd89b0f2c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (218,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NDMyNCwiaWF0IjoxNzc4NTY5NTI0LCJqdGkiOiJjYzU1MDdhODA3ZWE0ZjMyYjg2Njk0YmVlOTBhZjY5NCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.HnawzSj_WHPx22F_2_JolYKMd1cEGyagsf4tK_hXvww','2026-05-12 07:05:24.780685','2026-05-19 07:05:24',1,'cc5507a807ea4f32b86694bee90af694');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (219,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NDcyNSwiaWF0IjoxNzc4NTY5OTI1LCJqdGkiOiI5OTYyODE1MTc5OWU0NDExODhmYWI2MWM4N2VkODdkMyIsInVzZXJfaWQiOiI2In0.EXtKNSjcsbk7e6XXI4FL4L1ABClOTnU8KozGj1RkXEU','2026-05-12 07:12:05.750680','2026-05-19 07:12:05',6,'99628151799e441188fab61c87ed87d3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (220,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NTY1OCwiaWF0IjoxNzc4NTcwODU4LCJqdGkiOiI5MjgxNTY0ODkwYmM0YjViYjAzM2ZjNDNmOWE5ZTA2NCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.nUHWhJGe3-yezP1_1dVoBxWaO-SKZS5TZh_HMcQjsEk','2026-05-12 07:27:38.575317','2026-05-19 07:27:38',6,'9281564890bc4b5bb033fc43f9a9e064');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (221,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NTczMSwiaWF0IjoxNzc4NTcwOTMxLCJqdGkiOiJiZDNjOGQwYzJiNTk0MjAxYWFlZGNmNmRhOTE2NWNjMSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.0tC1uJasbocBloYectm3uIyxFOdvaS2Ue0l0YZtvq_Q','2026-05-12 07:28:51.819236','2026-05-19 07:28:51',6,'bd3c8d0c2b594201aaedcf6da9165cc1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (222,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NTczMSwiaWF0IjoxNzc4NTcwOTMxLCJqdGkiOiI2ZjU4NDYyMzJjOTg0NjUzODI0MjJmNjBiNzI2MmI1ZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.LN8aetO5nhVQ3Eznf9MDuc8yZUYKbXmYrTLuqwygXp4','2026-05-12 07:28:51.789607','2026-05-19 07:28:51',6,'6f5846232c98465382422f60b7262b5d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (223,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NzY2NSwiaWF0IjoxNzc4NTcyODY1LCJqdGkiOiIwMjJmZTUzM2RkMTQ0MzhkODc0N2E3NDE5MGNjNzUwZSIsInVzZXJfaWQiOiIxMSJ9.29jKceBI32dKsovQ95B41z2-1U16PdSBhHV_2qHrxhw','2026-05-12 08:01:05.080423','2026-05-19 08:01:05',11,'022fe533dd14438d8747a74190cc750e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (224,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NzY3MywiaWF0IjoxNzc4NTcyODczLCJqdGkiOiJkZjQ4YWY1Njc4Mzk0NTk2YTYxNmU5NWJlM2ZkZDhjZSIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.klVdBq6yBROqmUYWlO9a0Bf3GAfEVkfJHo-ywakZRNo','2026-05-12 08:01:13.973823','2026-05-19 08:01:13',11,'df48af5678394596a616e95be3fdd8ce');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (225,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3NzY3MywiaWF0IjoxNzc4NTcyODczLCJqdGkiOiI0MmZkMzMxOTQ0NDE0NWM5Yjk4NTJiMjUwZmM0NTdkYiIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.n703MgkQnoBArxyDR8uK8AODeMfpEDJslDTNzDZeLrY','2026-05-12 08:01:13.965170','2026-05-19 08:01:13',11,'42fd3319444145c9b9852b250fc457db');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (226,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODE0NCwiaWF0IjoxNzc4NTczMzQ0LCJqdGkiOiJhODczMjk5MmZhMzg0MGI2OWRhOTU0Y2VlN2NlYzUxZSIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.kXhac45g41QWB36Jf9RDU-znQr05XlcbI68FyU97nW0','2026-05-12 08:09:04.105765','2026-05-19 08:09:04',11,'a8732992fa3840b69da954cee7cec51e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (227,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODE0NCwiaWF0IjoxNzc4NTczMzQ0LCJqdGkiOiI1OTI2ZmE3ZGYyMjA0ZGIwYmZhN2Y0MDIyMzMxYjc1MCIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.mKQAXU4fkplUYQphr8O3JYszvNzSVXDOLRaSMK3XmdI','2026-05-12 08:09:04.112371','2026-05-19 08:09:04',11,'5926fa7df2204db0bfa7f4022331b750');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (228,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODczNCwiaWF0IjoxNzc4NTczOTM0LCJqdGkiOiJjMGY5OGRmMTZiYWI0Y2JiODEwMGFjOTFhZDAwZTc0ZSIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.2WttGuW-TqNo-vgCM_rZyg2TPlvezlDvzohux64fYzk','2026-05-12 08:18:54.678032','2026-05-19 08:18:54',11,'c0f98df16bab4cbb8100ac91ad00e74e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (229,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODczNCwiaWF0IjoxNzc4NTczOTM0LCJqdGkiOiI0Nzk5NTM0ZTA0YjU0OGUwYjI5MzRlNTg4YzExMjA5YSIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.o4H8otpMm5sXRiTCl1iwKTRFjue13ecKzzb-JpPK3Qk','2026-05-12 08:18:54.712954','2026-05-19 08:18:54',11,'4799534e04b548e0b2934e588c11209a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (230,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODc1MywiaWF0IjoxNzc4NTczOTUzLCJqdGkiOiI1ZDlmNTRkOGMyODg0ZDZjYTU0MWM4MmIxNGQ3ZjFiYiIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.TKUHExlAAPbf4Umx9Ork1b8kGHsZHpsMDSXOj6OtfGk','2026-05-12 08:19:13.224654','2026-05-19 08:19:13',11,'5d9f54d8c2884d6ca541c82b14d7f1bb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (231,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODc1MywiaWF0IjoxNzc4NTczOTUzLCJqdGkiOiJmMTllZjhiYzYyNGM0MGJhOTlhN2I3NjE5ZWViZDRmMSIsInVzZXJfaWQiOiIxMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0dXNlckBleGFtcGxlLmNvbSJ9.BOLs3N7h-sdM-5GCYj0h1TFrq4u4DZxFp-w-EVLtNG4','2026-05-12 08:19:13.231308','2026-05-19 08:19:13',11,'f19ef8bc624c40ba99a7b7619eebd4f1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (232,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODgwOSwiaWF0IjoxNzc4NTc0MDA5LCJqdGkiOiI1OGZiZmYyMjlmZmI0MjQ1YjA1NDFjODBlZDc2YzEzNyIsInVzZXJfaWQiOiIxIn0.XwoR_Zeyj3VRmXh-RLr20KpfDK514tW3lcg7kaFsv_M','2026-05-12 08:20:09.102369','2026-05-19 08:20:09',1,'58fbff229ffb4245b0541c80ed76c137');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (233,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODkxNiwiaWF0IjoxNzc4NTc0MTE2LCJqdGkiOiJmNjYyNmY5OGRmMGE0MzNjYjM0NGVmYjk1MDA4OWIxMCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.17zcQH4kyUdFPMO9dujRUSVrDRLDZFJLv_kubG_QprA','2026-05-12 08:21:56.108349','2026-05-19 08:21:56',1,'f6626f98df0a433cb344efb950089b10');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (234,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3ODkxNiwiaWF0IjoxNzc4NTc0MTE2LCJqdGkiOiI0Njk1ZThiY2QzOTE0OTdjODc4Y2U5M2NiOTVmOGVlOCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.LkB3SDV4270WcB11S-HFDiXo1O3Y7Vm84CKIGroak_8','2026-05-12 08:21:56.135182','2026-05-19 08:21:56',1,'4695e8bcd391497c878ce93cb95f8ee8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (235,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE3OTkwMiwiaWF0IjoxNzc4NTc1MTAyLCJqdGkiOiI0YzYwMjI4ZWRiMmY0NjI3OTQ4N2U5MjljNDUyNjVjZCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ._i4UuGlLKn4OlflYc4dGo2gRRfG9mYYQ9qt3nJ4t4JM','2026-05-12 08:38:22.045798','2026-05-19 08:38:22',1,'4c60228edb2f46279487e929c45265cd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (236,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDI1MCwiaWF0IjoxNzc4NTc1NDUwLCJqdGkiOiJjODY3ZDYyMTkxZDA0ZGUwOWI4M2FlYWM3NjhiZDBhZSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.fHHAkChOdzyBMvtZJgKA_fXeb8Md6g2A-Sd3Nh2I4Tg','2026-05-12 08:44:10.704115','2026-05-19 08:44:10',1,'c867d62191d04de09b83aeac768bd0ae');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (237,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDI1MCwiaWF0IjoxNzc4NTc1NDUwLCJqdGkiOiI0MmZhNWFiZjY2NTE0MGIxYWVhMjY4NmM5MjFhNzA5YyIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.b01Za29BWfEVeoEQUEwYOdhFWQVgRKxhaQRxwl6u94I','2026-05-12 08:44:10.645751','2026-05-19 08:44:10',1,'42fa5abf665140b1aea2686c921a709c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (238,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDU2NywiaWF0IjoxNzc4NTc1NzY3LCJqdGkiOiI5YzczMWE4MTgxMzI0M2U5ODY2YTcxYTY2ZTcyYWFlNCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.ufPmrV27QkEVqwFWB6YS3XYgdtEsYHSF6l_SUt52mps','2026-05-12 08:49:27.288478','2026-05-19 08:49:27',1,'9c731a81813243e9866a71a66e72aae4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (239,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDU2NywiaWF0IjoxNzc4NTc1NzY3LCJqdGkiOiJhNDliMmI3ODQ5MGQ0MTI2OWE4ZGM0N2E1MWRlYzA5MiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.0lJsC-IKNHk3rDx3pVYxdsDvL7cez2hNaEdOcIy3aXo','2026-05-12 08:49:27.311135','2026-05-19 08:49:27',1,'a49b2b78490d41269a8dc47a51dec092');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (240,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDYzMSwiaWF0IjoxNzc4NTc1ODMxLCJqdGkiOiIwOWUxN2UwYTE3ZDM0ZGQzYjZhMjQ1MTI2NTJlZjBlNSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.BII9SJBfvyZC_LM2WIw_RcMheVOxh0MFPoPrvecTRa8','2026-05-12 08:50:31.200257','2026-05-19 08:50:31',1,'09e17e0a17d34dd3b6a24512652ef0e5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (241,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDYzMSwiaWF0IjoxNzc4NTc1ODMxLCJqdGkiOiJhZjBiZmJjNWExMTc0YmFhOGM1NTVlOTAwOTYzNmIzNiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.4brLYhK-4AdcMCdPHP0lU5vVUiKoBbbgh6gpTam62FU','2026-05-12 08:50:31.212234','2026-05-19 08:50:31',1,'af0bfbc5a1174baa8c555e9009636b36');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (242,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDY4NCwiaWF0IjoxNzc4NTc1ODg0LCJqdGkiOiJjYTNhMTgzNzk5MTU0NTUzYmIwYTc5NzI0YzVkNzZiZCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.VZykeGh6f5uyDxwlk8IF94uROlKUI3nE0O4wrb4RZgo','2026-05-12 08:51:24.346840','2026-05-19 08:51:24',1,'ca3a183799154553bb0a79724c5d76bd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (243,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MDY4NCwiaWF0IjoxNzc4NTc1ODg0LCJqdGkiOiIxYTM0YjVmNDhiZDM0M2YxODkwMzNjNWExY2FlOGVjMiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.FSSks_jSEGr1ZZWwgQtWqZhwQscSaxw-1aUYUi1fBWM','2026-05-12 08:51:24.394031','2026-05-19 08:51:24',1,'1a34b5f48bd343f189033c5a1cae8ec2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (244,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4Mjc0MCwiaWF0IjoxNzc4NTc3OTQwLCJqdGkiOiJmODdkYTgwZTVlYzQ0NjcxOGI4YmRiOTNhNmM0ODc2YiIsInVzZXJfaWQiOiI2In0.EIWaBpwophu2g1_OT5weDFZidpB6YkDQT5Mc-HgrJQ4','2026-05-12 09:25:40.388456','2026-05-19 09:25:40',6,'f87da80e5ec446718b8bdb93a6c4876b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (245,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzE4OSwiaWF0IjoxNzc4NTc4Mzg5LCJqdGkiOiIyZWY2OWYyNmRjMjI0MjRmOTdjYjAyODBjM2NiMWViOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.-ZWGJHzBEkcOV1EwGoIwzWDe5UQLZmWrKCoPUjlRvCg','2026-05-12 09:33:09.675926','2026-05-19 09:33:09',6,'2ef69f26dc22424f97cb0280c3cb1eb9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (246,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzE4OSwiaWF0IjoxNzc4NTc4Mzg5LCJqdGkiOiI2OTczN2UxNjkzODA0ZWZmOGY1Y2VkNDg0MjE0ZGY4ZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.0d9EbLqCzABlYX0SOYTuixchJOAx5UYH3J2eJPJi5Y4','2026-05-12 09:33:09.676917','2026-05-19 09:33:09',6,'69737e1693804eff8f5ced484214df8d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (247,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzI2OSwiaWF0IjoxNzc4NTc4NDY5LCJqdGkiOiJhOGY0ZjkzMzJhNmM0NGRkYTIzZjBhNjA4NDUwN2I2OCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.-kwafXbf3vxY6blvFStx92Z_tE3YKA5mSUHcBpxiLJI','2026-05-12 09:34:29.263621','2026-05-19 09:34:29',1,'a8f4f9332a6c44dda23f0a6084507b68');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (248,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzI2OSwiaWF0IjoxNzc4NTc4NDY5LCJqdGkiOiIxMTliODViMDg5OTc0YjJjODdiNzk2YjYzODczNmQzNSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.KlDVOVayzntxN95IMWmMfyBhc2geOtYNJAk_hMuBTPc','2026-05-12 09:34:29.320294','2026-05-19 09:34:29',1,'119b85b089974b2c87b796b638736d35');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (249,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzM3MywiaWF0IjoxNzc4NTc4NTczLCJqdGkiOiIwZTc0MmI5MzI5Yjg0NzAyOGM2YmJkOGFiYzRkMzdlMyIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.JzpxilVfgC3t7cZ5DMMMYisGLzNnkovqIg19muHlsD4','2026-05-12 09:36:13.412653','2026-05-19 09:36:13',1,'0e742b9329b847028c6bbd8abc4d37e3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (250,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzM3MywiaWF0IjoxNzc4NTc4NTczLCJqdGkiOiI0NGU1ZTUwNDA2Yjg0ODk5YTJhNzgzZDUzYTY1YjNmYiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.VrnKV9xBk3fBtWYVQri9hGjJO9rXS7mdKQxI5JYkYJs','2026-05-12 09:36:13.492673','2026-05-19 09:36:13',1,'44e5e50406b84899a2a783d53a65b3fb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (251,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzQ0NCwiaWF0IjoxNzc4NTc4NjQ0LCJqdGkiOiIyZTU5MmRmZGExZTI0ZmE0OWJiMWY0ZTczNGRmMTA0OSIsInVzZXJfaWQiOiIxIn0.-0c1UWzaoVz7lPUjd4Nh_AVtUQFtue8go2RpiVCzhHY','2026-05-12 09:37:24.683059','2026-05-19 09:37:24',1,'2e592dfda1e24fa49bb1f4e734df1049');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (252,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzQ1NCwiaWF0IjoxNzc4NTc4NjU0LCJqdGkiOiI0MjcyMGQ4YTU3MDg0NzcwYmQzYWNhMjgwYjAwYmQ0MCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.4CeScOrPx4_R8ULSHO8Migf6t45Bu50TVGp-k0HR7lY','2026-05-12 09:37:34.658164','2026-05-19 09:37:34',1,'42720d8a57084770bd3aca280b00bd40');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (253,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzQ1NCwiaWF0IjoxNzc4NTc4NjU0LCJqdGkiOiI0NmU0OThmOTY5M2Y0ZmM3ODlhZjBjYjE2M2M0YWMzZCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.vK9xS1omENn4UeW_cbJGxkCZWW8uPrOzQyDo2VhoQI4','2026-05-12 09:37:34.653782','2026-05-19 09:37:34',1,'46e498f9693f4fc789af0cb163c4ac3d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (254,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzU1NywiaWF0IjoxNzc4NTc4NzU3LCJqdGkiOiI3MGJlZTM4ODY3OTU0YjliODJiMjJkOTM3YTA4NjY1MyIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.WiqtTFohirTIQVYLxUtmUdlDz1NcJ1aKTFIjmuyE9Zs','2026-05-12 09:39:17.526520','2026-05-19 09:39:17',1,'70bee38867954b9b82b22d937a086653');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (255,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzU1NywiaWF0IjoxNzc4NTc4NzU3LCJqdGkiOiIyNzNmOGNhNTJiODY0MDVkOGU3NWYzYmI3ODFlYTNjMiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.uHnonilTSfKjbzFm_VMzTZ6McZsX6O_ouhEeqPzvOzM','2026-05-12 09:39:17.552501','2026-05-19 09:39:17',1,'273f8ca52b86405d8e75f3bb781ea3c2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (256,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzYwNCwiaWF0IjoxNzc4NTc4ODA0LCJqdGkiOiJiZDE2OTY4M2E1Njc0ZjQ3YTcxOWE4ZGFmMzM5ZGY4MyIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.E7vHgjzn5vC22FLq2zBGZ34o1ofA8uVCzo9REnwzycA','2026-05-12 09:40:04.709217','2026-05-19 09:40:04',1,'bd169683a5674f47a719a8daf339df83');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (257,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzYwNCwiaWF0IjoxNzc4NTc4ODA0LCJqdGkiOiJkMGFkMzViNmE5OTk0MDIzYjdkZTNlZjMwZjdmMmY3ZCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.sawficqBRz86l3NLkCYsZnhXDtdErlF43n270KHcu8Y','2026-05-12 09:40:04.690003','2026-05-19 09:40:04',1,'d0ad35b6a9994023b7de3ef30f7f2f7d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (258,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzY0MiwiaWF0IjoxNzc4NTc4ODQyLCJqdGkiOiIxZGY1Y2RiMDJiZmQ0YWMzYjcwZWUxMjViYTc5ODk1YiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.Yn9zweGb0ZvkVOA3v7Q_TTkeTPse0VxJoxxLCMXqsfc','2026-05-12 09:40:42.721225','2026-05-19 09:40:42',1,'1df5cdb02bfd4ac3b70ee125ba79895b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (259,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzY0MiwiaWF0IjoxNzc4NTc4ODQyLCJqdGkiOiIyNTFjMGI2YmFkYjg0MWVmYjhjYTI3MGE0MDYyZDM3MiIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.g9-qBvsGWos7eedBVVKaP9XBgcLCiLrYUircetVTFqA','2026-05-12 09:40:42.732119','2026-05-19 09:40:42',1,'251c0b6badb841efb8ca270a4062d372');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (260,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzY2MCwiaWF0IjoxNzc4NTc4ODYwLCJqdGkiOiIxZjYzNDEwMWY0YWQ0N2M0OTczYzE5ZWUyNWZhNmExMyIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.Bjxhn5AvZCa3gaLMzhSh97MEvelyxMjqevRgHoN3W-A','2026-05-12 09:41:00.611905','2026-05-19 09:41:00',1,'1f634101f4ad47c4973c19ee25fa6a13');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (261,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzY2MCwiaWF0IjoxNzc4NTc4ODYwLCJqdGkiOiJmYTBhMmQwNDQyNzE0Y2YzYjg5Y2RmODE1NmUxNDAyNSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.Ov-SCVkUJN6iQZJ8IEHOcrNQXI4EB-hkn7ILtZUtLSw','2026-05-12 09:41:00.600245','2026-05-19 09:41:00',1,'fa0a2d0442714cf3b89cdf8156e14025');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (262,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTE4MzY4NSwiaWF0IjoxNzc4NTc4ODg1LCJqdGkiOiIwZDBjYzdhMzY2ODY0ZmJlYWRmNjRlOTA4YjVkZDUzZSIsInVzZXJfaWQiOiI2In0.4uyMdSRMWnpyH_8GqOrHJraCVGPI2g85xC1HjvZJt0Y','2026-05-12 09:41:25.151953','2026-05-19 09:41:25',6,'0d0cc7a366864fbeadf64e908b5dd53e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (263,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTY1MCwiaWF0IjoxNzc4NTk2ODUwLCJqdGkiOiJhOWRjZmY2NGZkMDA0NGVjYTk3ZTI3NWFjMzc5ODdmYyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.AxMrK2XBj0F257ZMu5loCqSeSwbSS_vbbYrUWambrJs','2026-05-12 14:40:50.956850','2026-05-19 14:40:50',6,'a9dcff64fd0044eca97e275ac37987fc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (264,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTY1MCwiaWF0IjoxNzc4NTk2ODUwLCJqdGkiOiI5NWRkOGM5Mzc0MmY0ZmZlYjVjMzIyNmY5Y2U3MTJlOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.gUL3TJZdGpliXe8hVrNboCqyiYdh9HI5yJPMviVDzJc','2026-05-12 14:40:50.958413','2026-05-19 14:40:50',6,'95dd8c93742f4ffeb5c3226f9ce712e9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (265,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTg0NSwiaWF0IjoxNzc4NTk3MDQ1LCJqdGkiOiIyM2ZiYjA4ZTkwMDY0OWQ1YTgzYmM5ZDE2MDBmOWRhMiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.dkfbQ1rIP8iESVJMgXzwJzzcp_bRWNsvzn56vi6f9xU','2026-05-12 14:44:05.136589','2026-05-19 14:44:05',6,'23fbb08e900649d5a83bc9d1600f9da2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (266,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTg0NSwiaWF0IjoxNzc4NTk3MDQ1LCJqdGkiOiI0MzBiMzhiZDYzNzk0NzVmODI4MmYyNTYyZmRlZjAyOCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.zfs3xKeREbBMZmQtbYPck53mg56ySlR-8mO7QQ4jVO8','2026-05-12 14:44:05.130065','2026-05-19 14:44:05',6,'430b38bd6379475f8282f2562fdef028');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (267,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTg3NSwiaWF0IjoxNzc4NTk3MDc1LCJqdGkiOiI0NGJjMDk5Y2RjMjU0OTg5YmY1MTQ4NzY3MjVhOGJiYiIsInVzZXJfaWQiOiI4In0.Ne0DcT9ETCYbgWUc376FI_cosSLDOaPgjojeYu7gGFY','2026-05-12 14:44:35.704241','2026-05-19 14:44:35',8,'44bc099cdc254989bf514876725a8bbb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (268,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTkyMCwiaWF0IjoxNzc4NTk3MTIwLCJqdGkiOiI2YmMyMjlhZmJhNDM0YzJjYmI0MWMzNzM3ZWE5MGQ1MSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.2LNw6byNcb1Nz1Vg2Ggc8dzSqm5uXVVaKxWCfCkE4SQ','2026-05-12 14:45:20.832074','2026-05-19 14:45:20',8,'6bc229afba434c2cbb41c3737ea90d51');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (269,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTkyMCwiaWF0IjoxNzc4NTk3MTIwLCJqdGkiOiI2OGM0OTBlMGQ4MDI0ZjgxODg2MTI1OWY0ZTk3NWY5ZCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.D3m9nu0NnAQ8SvW09D_JHBkkyJdAczQL_XyS-t__A4U','2026-05-12 14:45:20.816082','2026-05-19 14:45:20',8,'68c490e0d8024f818861259f4e975f9d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (270,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMTk1MiwiaWF0IjoxNzc4NTk3MTUyLCJqdGkiOiI2YzE4NGZhNWE5ZWU0YmFkYmM4ZTcwODljZmRjZjM0YiIsInVzZXJfaWQiOiI3In0.ooxVyyXc2A_6Z_M6SPfza3TGnZvqCDyeiQmSxix97H4','2026-05-12 14:45:52.231481','2026-05-19 14:45:52',7,'6c184fa5a9ee4badbc8e7089cfdcf34b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (271,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMjA4MywiaWF0IjoxNzc4NTk3MjgzLCJqdGkiOiIxMThmNzVhODc1MTc0MDRjOTU3MDQzMmQxZGI0NGMxNCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.3HMiXwsW-FAkOtSheGfe6XTs8nsgv9uyjLnkHcrbFaY','2026-05-12 14:48:03.788442','2026-05-19 14:48:03',6,'118f75a87517404c9570432d1db44c14');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (272,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMjA4MywiaWF0IjoxNzc4NTk3MjgzLCJqdGkiOiI2MzU1MjBjMmVmZGM0ZjJiYTE5NGFhMTdkZTBkOGU4YiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.PI24kZ5GOtUMwgwukz-HNAFDfjpyNGfhAvqQOtEzf0w','2026-05-12 14:48:03.792065','2026-05-19 14:48:03',6,'635520c2efdc4f2ba194aa17de0d8e8b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (273,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMzYyNSwiaWF0IjoxNzc4NTk4ODI1LCJqdGkiOiIwNjhiNzE3MDkzOTg0YjIwOTA1ZmUxOGM3OWZkZWI3YyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.mk4k7lbqZfUhWsHeX2Xr_cyTmOt-U5WgQrx7tSy9rXU','2026-05-12 15:13:45.667343','2026-05-19 15:13:45',6,'068b717093984b20905fe18c79fdeb7c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (274,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMzYyNSwiaWF0IjoxNzc4NTk4ODI1LCJqdGkiOiJmZTQ1ZTliNDg4ZTQ0MjQ4YTExZDM3OTI5ZDc5OTAzYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.k-T-dBJ5KtdSHXmRO5oO2SUT6FrKwCCNFiziZb8a40k','2026-05-12 15:13:45.667993','2026-05-19 15:13:45',6,'fe45e9b488e44248a11d37929d79903a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (275,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMzYyOSwiaWF0IjoxNzc4NTk4ODI5LCJqdGkiOiIwNzE3MGU4OGJkMGM0OWQ4OTFhMWUzOTM3ZTFjMDk2NyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.vqTk1hFXZVHfAAjzlmqDHC5cbN8BiRK7ydppR5sv5z4','2026-05-12 15:13:49.365177','2026-05-19 15:13:49',6,'07170e88bd0c49d891a1e3937e1c0967');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (276,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwMzYyOSwiaWF0IjoxNzc4NTk4ODI5LCJqdGkiOiI1YTRjZWM3YzVjZTg0MmI0ODk5NGZjNTNmNDdkZTFiYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.qW5Z5HiQjhfdnQqFBhtCMj-wp99_kUwmJV8rv48KJuU','2026-05-12 15:13:49.370294','2026-05-19 15:13:49',6,'5a4cec7c5ce842b48994fc53f47de1ba');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (277,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDAxNiwiaWF0IjoxNzc4NTk5MjE2LCJqdGkiOiJhNzVmOGU5ZDU0YTc0ZWRlOTg1MTEyZjFhNGFmM2Y4NSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.RuY0TEXvzsIZqX-zrzJmHoxu9giheqR8bjOtCmOP2hU','2026-05-12 15:20:16.190725','2026-05-19 15:20:16',6,'a75f8e9d54a74ede985112f1a4af3f85');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (278,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDAxNiwiaWF0IjoxNzc4NTk5MjE2LCJqdGkiOiI1YmJmMzdhMTc1M2M0MzcwYWE0NmRlN2FiYWIyN2E1OSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.O-WXxDB2UBkteais6rJxNXV0X98NW-vFfOgjGu2w3Zs','2026-05-12 15:20:16.185457','2026-05-19 15:20:16',6,'5bbf37a1753c4370aa46de7abab27a59');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (279,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDE2MCwiaWF0IjoxNzc4NTk5MzYwLCJqdGkiOiI1OTNkNzNhNDU4ZDQ0OWQwYmNjNzYwNGRmODU1YmMxMiIsInVzZXJfaWQiOiI4In0.c84si_qvzs2gvts9PCZBa7Rl_W4XXyjTERoDq1LmEVw','2026-05-12 15:22:40.310612','2026-05-19 15:22:40',8,'593d73a458d449d0bcc7604df855bc12');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (280,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDQ2OSwiaWF0IjoxNzc4NTk5NjY5LCJqdGkiOiI5MzRkNGQ3MDI0Yzc0YWYyOTJmMjY5NTY0YjljNTllMCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.F-jbCUwa_a8bc3xn6bKrrEKVio1tAD0pWtwpsVuxiIQ','2026-05-12 15:27:49.127594','2026-05-19 15:27:49',8,'934d4d7024c74af292f269564b9c59e0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (281,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDQ3MiwiaWF0IjoxNzc4NTk5NjcyLCJqdGkiOiIxYTJjNmNjNTNjYjE0MWY2OGI2ZWUwM2JhNzU3N2RiYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.hv3lJNFfK9635tZAt2uOeaAGpND5i86V2z-K6TlJs2I','2026-05-12 15:27:52.604958','2026-05-19 15:27:52',6,'1a2c6cc53cb141f68b6ee03ba7577dba');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (282,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDQ3MiwiaWF0IjoxNzc4NTk5NjcyLCJqdGkiOiI2NjhlMTM3NzYxNTA0ZjAzYTc1YmFkMmUwYjc0ZmJkYiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.NwdiYXDw36pacyVL0fTO09X-CNPFJhQCl-gO-LvWrQg','2026-05-12 15:27:52.646466','2026-05-19 15:27:52',6,'668e137761504f03a75bad2e0b74fbdb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (283,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDg5MywiaWF0IjoxNzc4NjAwMDkzLCJqdGkiOiJiYzBlZTVlZWNlYmM0ZGFjOGIyZTQ2YTMyZDQ1Y2ZiOSIsInVzZXJfaWQiOiI4In0.71nrO0pmlmgGofJNhkDQC0CIDEtI4NG3zNXlqpPQA38','2026-05-12 15:34:53.625690','2026-05-19 15:34:53',8,'bc0ee5eecebc4dac8b2e46a32d45cfb9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (284,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDkzMCwiaWF0IjoxNzc4NjAwMTMwLCJqdGkiOiJlZGIwMGMxOTk5ODM0MTg5OWU5ODNmMjY5NjU4YWNjZCIsInVzZXJfaWQiOiI4In0.lsQQad9b3Z5AZRYq1FuMqMH4yUu-Y51hmDa7SjPAiIU','2026-05-12 15:35:30.157189','2026-05-19 15:35:30',8,'edb00c19998341899e983f269658accd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (285,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNDk4NywiaWF0IjoxNzc4NjAwMTg3LCJqdGkiOiI4ZTFlZWEyZTI3YWI0MjkyOWUzZjg3NDVmYjk3NDI0ZiIsInVzZXJfaWQiOiI4In0.7KydOQPyP89nRlr3u5N-mrGWk04K9u44OWgY2VTM1Cc','2026-05-12 15:36:27.302033','2026-05-19 15:36:27',8,'8e1eea2e27ab42929e3f8745fb97424f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (286,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTQ0NywiaWF0IjoxNzc4NjAwNjQ3LCJqdGkiOiI2M2RiYmI5ZDk5Yjk0NWJkYWU2YzEyMGIwMjlhYjIxNyIsInVzZXJfaWQiOiI4In0.eAn0dts-k6mEiDl52rcWxaaysrErrArSUnj6Vtahsb8','2026-05-12 15:44:07.538912','2026-05-19 15:44:07',8,'63dbbb9d99b945bdae6c120b029ab217');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (287,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTUyMiwiaWF0IjoxNzc4NjAwNzIyLCJqdGkiOiI3YzU5ODA2ZmM0ZmY0M2ZlOGJlMzNmOThmZDc3YjNiOCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.hKb6MOuQWPfi7qrEL2N8KfdqBn6Tq58mPcAI5fHOYfU','2026-05-12 15:45:22.375032','2026-05-19 15:45:22',8,'7c59806fc4ff43fe8be33f98fd77b3b8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (288,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTUyMiwiaWF0IjoxNzc4NjAwNzIyLCJqdGkiOiJiZDlmYjVjMzY4ZDk0NDdhOTMwZTk1ZWE4MDBkMGI3OCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.YkgYu5huLNF2n7i4QZi7N6RxvLmrgzDgLaBGompt3mU','2026-05-12 15:45:22.355104','2026-05-19 15:45:22',8,'bd9fb5c368d9447a930e95ea800d0b78');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (289,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTY2NywiaWF0IjoxNzc4NjAwODY3LCJqdGkiOiIyMzEzMGE0NTc2NTA0MmNkYjJiNzRmNzg2NzhlNGI0ZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.pLyhekaZotGCCuNoqs_WGfun9h5wf8TVMU16bh_y3zI','2026-05-12 15:47:47.297028','2026-05-19 15:47:47',8,'23130a45765042cdb2b74f78678e4b4f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (290,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTY2NywiaWF0IjoxNzc4NjAwODY3LCJqdGkiOiI0NmVmNjNjYTRiZjc0MjY0YmY5YzhkZGVlYTZkMDRjNiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.hAnNk-SC0UYpx4zq8oR10p-bBDaajgAF3JdnseXE0cE','2026-05-12 15:47:47.502218','2026-05-19 15:47:47',8,'46ef63ca4bf74264bf9c8ddeea6d04c6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (291,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTk1MiwiaWF0IjoxNzc4NjAxMTUyLCJqdGkiOiJkMzIxOGFiZWU1MTY0YTI1ODllNjlhYjY1MWZiZTcwYiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.oaESEgdSr88PGoojB5TU3uv5kZfHh5TuoFOqyIxTRbo','2026-05-12 15:52:32.678954','2026-05-19 15:52:32',8,'d3218abee5164a2589e69ab651fbe70b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (292,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNTk1MiwiaWF0IjoxNzc4NjAxMTUyLCJqdGkiOiJjNTkwMWZjZjI4YWQ0ZWM5OGI3NmJmYWZiMTJiMWRiNyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.KOKvcTrHqDoOW_-fiCjrwLrBRCof_9tx_uzJ4tPYdRM','2026-05-12 15:52:32.671972','2026-05-19 15:52:32',8,'c5901fcf28ad4ec98b76bfafb12b1db7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (293,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjAwMCwiaWF0IjoxNzc4NjAxMjAwLCJqdGkiOiI3NWM2OTJjZWMzODg0ZmUzYTdhMGE3ZjMzMWNjZTIwYSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.FhJXpGarecCCm6my-xHS1bBZI_JBjDEBvGS2pjkqPDE','2026-05-12 15:53:20.872429','2026-05-19 15:53:20',8,'75c692cec3884fe3a7a0a7f331cce20a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (294,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjAwMCwiaWF0IjoxNzc4NjAxMjAwLCJqdGkiOiI1M2RlNDkyOTQyOTI0MDdkOTkxNWJlZjJjOGI2ZTE2OCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.trto1meRkQ7lqt70iAomBB6uVeKVA0t6nCKq3jrvQdM','2026-05-12 15:53:20.847251','2026-05-19 15:53:20',8,'53de49294292407d9915bef2c8b6e168');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (295,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjAzOCwiaWF0IjoxNzc4NjAxMjM4LCJqdGkiOiJhM2FlNjhhNDljNTc0ZTVhOTEzMGZhOWY3ZmYwOWZlMiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.ST5abn5e3aLn2QBNDLs9iS97Jk2ifxhnoQstUtxwm_0','2026-05-12 15:53:58.118682','2026-05-19 15:53:58',8,'a3ae68a49c574e5a9130fa9f7ff09fe2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (296,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjAzOCwiaWF0IjoxNzc4NjAxMjM4LCJqdGkiOiIwYTE4NzJmMWEwNDA0Zjg0ODNkMDJmODY3NWY1ODdjOSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.kePMJ_a-PTdl_4IL22T7FHYiLQjI7_0NS5-PSjU6XfM','2026-05-12 15:53:58.110338','2026-05-19 15:53:58',8,'0a1872f1a0404f8483d02f8675f587c9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (297,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjA1MCwiaWF0IjoxNzc4NjAxMjUwLCJqdGkiOiJjZDg5MThlM2I5ZmE0YmU4YTI4OWUzYTY2ZDFjZGM5NCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.lO0PVyBL6iNNAvbwFetbY9jhPWm5HUdLc6aiZ_cbFYw','2026-05-12 15:54:10.135805','2026-05-19 15:54:10',8,'cd8918e3b9fa4be8a289e3a66d1cdc94');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (298,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjA1MCwiaWF0IjoxNzc4NjAxMjUwLCJqdGkiOiI2YTUzZGFjNWVlZWY0YjNkYWM5MzdjYTI3YzRjOWI0ZSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.iDPUzebi3eLUULXpU8iYx_fOgXNuZTaIXThcYgOb9lQ','2026-05-12 15:54:10.110070','2026-05-19 15:54:10',8,'6a53dac5eeef4b3dac937ca27c4c9b4e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (299,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjM1MSwiaWF0IjoxNzc4NjAxNTUxLCJqdGkiOiI1NGNjY2I5MDY2YWY0MTM5YjdjNjFmMTczODQyNDdkZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.IrisXNtPZt1mUl72EW_2tm1ReWdhMRVvbBO1P7N0IMQ','2026-05-12 15:59:11.778092','2026-05-19 15:59:11',8,'54cccb9066af4139b7c61f17384247df');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (300,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjM1MSwiaWF0IjoxNzc4NjAxNTUxLCJqdGkiOiI4MzE3NjMyOGI1N2M0ODZiOGM0YTFmYjg2NGU4MWE1YiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.3-YTcFXbyjpihrRAmpMH4eTpDbGRH6NIi4yBXtd_XSI','2026-05-12 15:59:11.891635','2026-05-19 15:59:11',8,'83176328b57c486b8c4a1fb864e81a5b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (301,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjUzOCwiaWF0IjoxNzc4NjAxNzM4LCJqdGkiOiI5YzgxMDkxY2IyNTQ0ZTE4OTFiZTIwMDk2OTRlNTcyMiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.aud-AUgepu81OFqU6VP_2Z_CSAb0XtfOjgOU7r77E00','2026-05-12 16:02:18.047257','2026-05-19 16:02:18',8,'9c81091cb2544e1891be2009694e5722');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (302,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjUzOCwiaWF0IjoxNzc4NjAxNzM4LCJqdGkiOiIzODVkYjkzYWMyMjM0ZWVlYmRmZDNmZDU1NmVjM2RjYiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.Z4l2vVxUBz10To2kbUcrPADV6mkSVo3wpJxbmPBxL3E','2026-05-12 16:02:18.059946','2026-05-19 16:02:18',8,'385db93ac2234eeebdfd3fd556ec3dcb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (303,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjY2OSwiaWF0IjoxNzc4NjAxODY5LCJqdGkiOiI0MjRlMjRjMTZiYTM0Y2MxYTQ4MTM1MWJmMjNjOTRkYyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.lpGn9l0erZACABOMa7J4JrmcWJdlSfNMcZkxJNlXGio','2026-05-12 16:04:29.725721','2026-05-19 16:04:29',8,'424e24c16ba34cc1a481351bf23c94dc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (304,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjY2OSwiaWF0IjoxNzc4NjAxODY5LCJqdGkiOiI4ZmFkZDBiMTZjNDc0Zjc3YWMzZjRiODJmMjkxZWI1YyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.UBkm3U69qKl0EbfTPuG6UoVv3WYg1I5MDGj5CWkblZk','2026-05-12 16:04:29.759506','2026-05-19 16:04:29',8,'8fadd0b16c474f77ac3f4b82f291eb5c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (305,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjkxNiwiaWF0IjoxNzc4NjAyMTE2LCJqdGkiOiI0ODE2ZDk4OWFhMWM0OTBjYjAzNWU4Mjg2MDkwZDdhNiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.51zvB76f753ZICvmJoFd7ObYIyqYnQAun_hQgiI1PP0','2026-05-12 16:08:36.668336','2026-05-19 16:08:36',8,'4816d989aa1c490cb035e8286090d7a6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (306,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNjkxNiwiaWF0IjoxNzc4NjAyMTE2LCJqdGkiOiI5MGI1YTgyZDRkZDI0NDJiYWU4OGE3NjIxODJiNTU3NyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.ndJYkZJa853FW1dpwvtEu2xMjrv5XPgEoVC-9Kt3l7A','2026-05-12 16:08:36.589966','2026-05-19 16:08:36',8,'90b5a82d4dd2442bae88a762182b5577');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (307,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzE5MiwiaWF0IjoxNzc4NjAyMzkyLCJqdGkiOiI2YmVjYzA5ZmFjZjI0MTcyYjk5ZDAxOTBjZjk5YzBlMiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0._jWONthmNLTRZLo0v0UBZxt4XL9Fhj4DE6yVON1rITw','2026-05-12 16:13:12.829833','2026-05-19 16:13:12',8,'6becc09facf24172b99d0190cf99c0e2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (308,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzE5MiwiaWF0IjoxNzc4NjAyMzkyLCJqdGkiOiIwNzQ1ZGQ0ZGUwMTk0ODNmODNjMDEyMTM0YzNiODE2YSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.Ik7W8Zii9oTTVjwlqjLMlwMNQtopiv5FeZpDq_N7n8U','2026-05-12 16:13:12.768511','2026-05-19 16:13:12',8,'0745dd4de019483f83c012134c3b816a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (309,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQwNCwiaWF0IjoxNzc4NjAyNjA0LCJqdGkiOiI0NzIzZWU4MDM2MTI0M2YxYjBiNWRjODA4NmNmY2NkMSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.l4f4L7E8DUZUg0J-NhTxQ9POu4HB5t66inFbZcrVCrY','2026-05-12 16:16:44.530230','2026-05-19 16:16:44',8,'4723ee80361243f1b0b5dc8086cfccd1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (310,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQwNCwiaWF0IjoxNzc4NjAyNjA0LCJqdGkiOiI2ZmU5NmMxYmE2Yjc0ZjA3YWU1ZDA4ZmM0Njk0YThlMyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.5UpruCW2n1DtamOk388sEZNkl9K2Vpj8k0c64iysbWw','2026-05-12 16:16:44.514525','2026-05-19 16:16:44',8,'6fe96c1ba6b74f07ae5d08fc4694a8e3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (311,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQyNiwiaWF0IjoxNzc4NjAyNjI2LCJqdGkiOiJmZWNmZmM1MzdjMzc0OTZkOGE1YmRlNzY0Mjk3OTE4NiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.O_Aw9MCih2-ZAzrOj6-UG4JL99JrnKNQZRAbpWuPWqk','2026-05-12 16:17:06.527818','2026-05-19 16:17:06',8,'fecffc537c37496d8a5bde7642979186');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (312,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQyNiwiaWF0IjoxNzc4NjAyNjI2LCJqdGkiOiJjMGE3NDM5OTcxMWQ0ZWUzYmI3ZWIxYWYxODRkOWI5NiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.TM61oPu8wb9GeEDlbG6m3Z0CVezUnlR93xF9CnsUlsY','2026-05-12 16:17:06.558567','2026-05-19 16:17:06',8,'c0a74399711d4ee3bb7eb1af184d9b96');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (313,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQ0MywiaWF0IjoxNzc4NjAyNjQzLCJqdGkiOiI1YjU3NmUzNDE4M2U0MzA3OTc4MGYyOWVmMmE4NjJkYyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.Venzaao21-Rn0ik1rarazd94iptm-hY3eY9oVLxJpmw','2026-05-12 16:17:23.299327','2026-05-19 16:17:23',8,'5b576e34183e43079780f29ef2a862dc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (314,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQ0MywiaWF0IjoxNzc4NjAyNjQzLCJqdGkiOiI3ZGM1ZTIzZDFlM2I0MTAxODYyZDI5ZjAwOGNlNmZmOCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.MXV5jV4LaJ5tWqE3Bq52o2YgDcx7QFFw7eA7zuqo1M4','2026-05-12 16:17:23.310810','2026-05-19 16:17:23',8,'7dc5e23d1e3b4101862d29f008ce6ff8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (315,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzQ4OSwiaWF0IjoxNzc4NjAyNjg5LCJqdGkiOiI5MjQ0OThiYjhmMDA0YzFjYjljYmRiNmNkOTE0Y2NiMCIsInVzZXJfaWQiOiI4In0.MorCN-POQZQpDILehhFDFKsbXgyUlkf4pB79Q7VQGPk','2026-05-12 16:18:09.607742','2026-05-19 16:18:09',8,'924498bb8f004c1cb9cbdb6cd914ccb0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (316,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzU2OCwiaWF0IjoxNzc4NjAyNzY4LCJqdGkiOiJkYmUyZWEwYzQ5YzA0ODJhOTZjZDQ2NWIwYjI0MzdkNyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.2cWRKFa7qXGBdNilFRUygYVUIRD9rpWx1Zi1_CvFquw','2026-05-12 16:19:28.114219','2026-05-19 16:19:28',8,'dbe2ea0c49c0482a96cd465b0b2437d7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (317,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzU2OCwiaWF0IjoxNzc4NjAyNzY4LCJqdGkiOiIyOWM3Njk5MzUzNTE0OWNjOGRjODI1MzEyZmRkODI3ZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.8wkDSLqhmKMt85QGeI5bf95ZTolWxM4quPBpkzXT3nM','2026-05-12 16:19:28.140881','2026-05-19 16:19:28',8,'29c76993535149cc8dc825312fdd827f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (318,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzU4NCwiaWF0IjoxNzc4NjAyNzg0LCJqdGkiOiIzY2Q4MmNkZDUzOWY0NDQzOWM5MmRiM2VmNGVjOWFlNSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.er3xrwFCvjhn3SXzMWaCc-8KkAkAq-laQDbT1crvboI','2026-05-12 16:19:44.174666','2026-05-19 16:19:44',8,'3cd82cdd539f44439c92db3ef4ec9ae5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (319,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzU4NCwiaWF0IjoxNzc4NjAyNzg0LCJqdGkiOiJhMmJkOTY2NzM1NGE0MGZkOGE3ZmE3YzM4N2FkM2ZjOCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.SKvlg5lEFyujGwN6z5AcU7VeQMXqPsAweDKKDDWKZaw','2026-05-12 16:19:44.285721','2026-05-19 16:19:44',8,'a2bd9667354a40fd8a7fa7c387ad3fc8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (320,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzU5MiwiaWF0IjoxNzc4NjAyNzkyLCJqdGkiOiIzNzlhNGU0Y2I3OTg0N2U5ODI0NjA3MzI4NzVhZmY2YiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.zisR3Nwf8N2PEN02tBx6w8rzT6JulZJjHV3-SdxWto4','2026-05-12 16:19:52.445190','2026-05-19 16:19:52',8,'379a4e4cb79847e982460732875aff6b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (321,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzU5MiwiaWF0IjoxNzc4NjAyNzkyLCJqdGkiOiJhOWM4YjFhODUwYWM0MjE4YjljNjA0NGQ5ZWEwM2E1ZSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.fRwG94_29El67qeDq2STJyDQ3nJ1_iqWkw-Q9kttLJs','2026-05-12 16:19:52.428828','2026-05-19 16:19:52',8,'a9c8b1a850ac4218b9c6044d9ea03a5e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (322,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY0MywiaWF0IjoxNzc4NjAyODQzLCJqdGkiOiI1MWM1YjQxODc4MGQ0Nzc5ODQ1OTY1YzQ4ZjFiOGY0ZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.1UaELn4qL43SSZT-AJZmCRXbxdLD8qKMqVpogmy5ZLc','2026-05-12 16:20:43.454617','2026-05-19 16:20:43',8,'51c5b418780d4779845965c48f1b8f4f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (323,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY0MywiaWF0IjoxNzc4NjAyODQzLCJqdGkiOiIxZmQ1NWM5ZmUyMTM0MzYwYmVlYmNlY2JiNjVlZDNmNSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.__3bYWKqtfRX70yHZDovuk7o9FEmE7Bz554-SBQ2pE0','2026-05-12 16:20:43.443199','2026-05-19 16:20:43',8,'1fd55c9fe2134360beebcecbb65ed3f5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (324,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY0OSwiaWF0IjoxNzc4NjAyODQ5LCJqdGkiOiI2Y2M0NDQ2NzczNmI0NWY0YmIyMmM4Y2I3NDQ1Y2JmMCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.GMj1TW2cNhxFwPxKwM__-FHmoWRyTubzdkYxKCQk3hc','2026-05-12 16:20:49.469911','2026-05-19 16:20:49',8,'6cc44467736b45f4bb22c8cb7445cbf0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (325,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY0OSwiaWF0IjoxNzc4NjAyODQ5LCJqdGkiOiI1N2VkMWE2ZTA0N2E0MTJhOTI4MzA4ODA1NmE2ZGY3YSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.Qp5M4gBfYN3OpDTcdTWra8zAMSe9v_yjtSf8CS3m9Gw','2026-05-12 16:20:49.464043','2026-05-19 16:20:49',8,'57ed1a6e047a412a9283088056a6df7a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (326,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY3MiwiaWF0IjoxNzc4NjAyODcyLCJqdGkiOiI1OTEwNjZiY2U4ZTk0NzU4YWEwNjNkZjhiNGY0NzQ4NiIsInVzZXJfaWQiOiI4In0.BCxIFUBvchDiXSZMqO_JfZrco7v8OOBxk6anqVHEyVY','2026-05-12 16:21:12.285361','2026-05-19 16:21:12',8,'591066bce8e94758aa063df8b4f47486');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (327,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY3NiwiaWF0IjoxNzc4NjAyODc2LCJqdGkiOiJkZDBmODM3YmQ2YmE0MjlmODIwYTYwNTc2MGNmNjVkOSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.4FTs2LyJaVhedZbhVCIDKbbEAzIPdrkx7hcVzGlpdp8','2026-05-12 16:21:16.700547','2026-05-19 16:21:16',8,'dd0f837bd6ba429f820a605760cf65d9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (328,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY3NiwiaWF0IjoxNzc4NjAyODc2LCJqdGkiOiJiMjZkMjExYmMyOTU0YmUyOThhYjk4YzM0YjkwZGM3NiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.X780K-ZouGMz4uxfuHZ1qTKP01oP07qZQGJfxrTHFz4','2026-05-12 16:21:16.689048','2026-05-19 16:21:16',8,'b26d211bc2954be298ab98c34b90dc76');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (329,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY4OCwiaWF0IjoxNzc4NjAyODg4LCJqdGkiOiI2M2U5YTM0MTViYmQ0MzEzODI1OThmNWY5NjBkYmZmZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.0KsAJXu-JOGelAGyrOHXVtUCYZHjVqMSseNQbDFPFFw','2026-05-12 16:21:28.574652','2026-05-19 16:21:28',8,'63e9a3415bbd431382598f5f960dbfff');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (330,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzY4OCwiaWF0IjoxNzc4NjAyODg4LCJqdGkiOiJhM2RhNjJjNDYzNTg0ZDhlYmY0NWE3ZDdhYmUxNWQ3NCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.WaOujEeWbLvvB_UKs4eD02M1bDf92qx6aYm7OtXLKss','2026-05-12 16:21:28.521289','2026-05-19 16:21:28',8,'a3da62c463584d8ebf45a7d7abe15d74');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (331,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzcyMSwiaWF0IjoxNzc4NjAyOTIxLCJqdGkiOiI2ODkwYTJkYjY2ODQ0NWNkODU2MjRjMjEyMDY1YmI0YiIsInVzZXJfaWQiOiI4In0.kC3w3ZdXjTDCBtBly8HPRjPSImiPmgetNviWLXapUtc','2026-05-12 16:22:01.205188','2026-05-19 16:22:01',8,'6890a2db668445cd85624c212065bb4b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (332,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzcyOSwiaWF0IjoxNzc4NjAyOTI5LCJqdGkiOiI3Y2E1NTU1OTNhNGY0NWU0ODNhZjhhZGRmOTljYWE0NyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.bqVhSkaCPMT0tjXwx22pfDlyCSeIhd1PQphJ6xVlC8Q','2026-05-12 16:22:09.208451','2026-05-19 16:22:09',8,'7ca555593a4f45e483af8addf99caa47');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (333,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzcyOSwiaWF0IjoxNzc4NjAyOTI5LCJqdGkiOiI4NzdhNTI5YmZjYjY0OTJiOTFkYTk4YWY4MDIxMTc0YSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.cWvY9stJt_HuwSQXZ6LwMb1hjg7-DO1-PltN1dsdxBY','2026-05-12 16:22:09.199821','2026-05-19 16:22:09',8,'877a529bfcb6492b91da98af8021174a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (334,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzczNywiaWF0IjoxNzc4NjAyOTM3LCJqdGkiOiJjYzViMjNjODJiMzE0NjNmYTY2NGQ5NzZiZjY4ZmNjMSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.N1T97lw31GeWPEtYmO1IQ40e92vxPwNRgTqGFU3alwk','2026-05-12 16:22:17.568430','2026-05-19 16:22:17',8,'cc5b23c82b31463fa664d976bf68fcc1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (335,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwNzc4MiwiaWF0IjoxNzc4NjAyOTgyLCJqdGkiOiIwZTRmZDRkZjgzMmU0NGZmYjdhYzVkYzljMWI4YmQwZCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.FU0OYN7dSD223Wb8YcDz-DWkU79sMuppZG847dJ4PDw','2026-05-12 16:23:02.856110','2026-05-19 16:23:02',8,'0e4fd4df832e44ffb7ac5dc9c1b8bd0d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (336,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODAwNCwiaWF0IjoxNzc4NjAzMjA0LCJqdGkiOiJlZmU4MTA3MDYxY2E0NjNmOGRlYjU5ZDY5ZjJmNzkyOSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.mgOQJVTcVbV_0MZdKmhPcytgJ1stH2lVGGYAGP-9S5c','2026-05-12 16:26:44.184877','2026-05-19 16:26:44',8,'efe8107061ca463f8deb59d69f2f7929');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (337,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODAwNCwiaWF0IjoxNzc4NjAzMjA0LCJqdGkiOiI1Y2M1NGQ5NGIzMjc0YWU5YmE3MGMyMTJjMjY3ZDQ2ZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.zbjWo3-LOCuxycsrv9UYaRNDIMj1m2oOrQYZdacs9mE','2026-05-12 16:26:44.088652','2026-05-19 16:26:44',8,'5cc54d94b3274ae9ba70c212c267d46f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (338,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODAxNywiaWF0IjoxNzc4NjAzMjE3LCJqdGkiOiI1NzI5YTE5NDgwZTI0NjBkYTVjMWQ5MGJjZDk4MDVmMiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.YhemruCVq8x9458aHtN39wE_OHDpYNCXbrzZ74tross','2026-05-12 16:26:57.756927','2026-05-19 16:26:57',8,'5729a19480e2460da5c1d90bcd9805f2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (339,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODAxNywiaWF0IjoxNzc4NjAzMjE3LCJqdGkiOiIxNjhiNjA2NGIyZjM0ODlkOWFiNjQ5OWZiZWJiMDBiNSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.HkiRHe-v_G2tXne_l_4ri_y0fDpIrth7Urg8zWkeahA','2026-05-12 16:26:57.769277','2026-05-19 16:26:57',8,'168b6064b2f3489d9ab6499fbebb00b5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (340,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODA0OSwiaWF0IjoxNzc4NjAzMjQ5LCJqdGkiOiJlMjFlYmNiMTAzM2U0NjBjYTZiMGY3ZGEyOTIxYjQ2YSIsInVzZXJfaWQiOiI4In0.4Y77X-7gvRSxGLEwdARsVU6BheqWObjruj4m7sURBiM','2026-05-12 16:27:29.213668','2026-05-19 16:27:29',8,'e21ebcb1033e460ca6b0f7da2921b46a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (341,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODA1NSwiaWF0IjoxNzc4NjAzMjU1LCJqdGkiOiIyMWU4Yjk0ZGExZTk0MWJmOTVjZjdkYzE1ZGMwYzllYiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.HCsJDy4CLyGhleVOj3LoSgZ1CD6KIZnM68t7GW9K8jc','2026-05-12 16:27:35.190791','2026-05-19 16:27:35',8,'21e8b94da1e941bf95cf7dc15dc0c9eb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (342,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODA2NSwiaWF0IjoxNzc4NjAzMjY1LCJqdGkiOiI1OTljMjI1OTQ0ZmQ0YmIyYjRkODIxYTUxMTc3NDQ2NyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.Jn4tyv85ArAIqjESek2y_xyexooIkBZGhAoaUMUUdSw','2026-05-12 16:27:45.367575','2026-05-19 16:27:45',8,'599c225944fd4bb2b4d821a511774467');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (343,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODA2NSwiaWF0IjoxNzc4NjAzMjY1LCJqdGkiOiIyYjFlNDhkMTMzOGQ0ZWQzOThkYzFkZDkyODRhODk5YSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.RJMJEtODFhFYF6IJZkH7Bh9X5b66O6RuAXO422w4sTw','2026-05-12 16:27:45.198254','2026-05-19 16:27:45',8,'2b1e48d1338d4ed398dc1dd9284a899a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (344,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODA3NywiaWF0IjoxNzc4NjAzMjc3LCJqdGkiOiI0ZTg2ZjcxYzM2NzY0N2Y0YTkyZDQ2NGI3NzAzY2QzOSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.NYdJDX8zkyglQjuw10ULI651TwXrjoXJsPTb4tKXoNQ','2026-05-12 16:27:57.526491','2026-05-19 16:27:57',8,'4e86f71c367647f4a92d464b7703cd39');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (345,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIwODA3NywiaWF0IjoxNzc4NjAzMjc3LCJqdGkiOiJkZTRjMGUyN2VmMWY0NTQ4OTdiZTBlOWE0YTZlZTZmMCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.KlhEuPpF7PEKT4T7BgyEl3AVM4Zzr9veJXqpb2C4wxI','2026-05-12 16:27:57.483905','2026-05-19 16:27:57',8,'de4c0e27ef1f454897be0e9a4a6ee6f0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (346,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIxMTUwNywiaWF0IjoxNzc4NjA2NzA3LCJqdGkiOiJjYzMxMTc3NjBkMjQ0ZDg3ODNkOTg2NTY3YmI1NmQ4YyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.azmJY36RJoXB_yQ6RRu8QPKMDpnquamZLSFfoh-RWZw','2026-05-12 17:25:07.351424','2026-05-19 17:25:07',8,'cc3117760d244d8783d986567bb56d8c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (347,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIxMTUwNywiaWF0IjoxNzc4NjA2NzA3LCJqdGkiOiJkZjgwYzU3MjljNzc0ZGMwOGE0NjczZjU2YjQxN2Q1MSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.4z2PSXaHdzjCN4U89t0MCwNqG8RHrJEZwmdgWAYsOaI','2026-05-12 17:25:07.411987','2026-05-19 17:25:07',8,'df80c5729c774dc08a4673f56b417d51');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (348,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTIxMTU1MywiaWF0IjoxNzc4NjA2NzUzLCJqdGkiOiJlMzVmY2Q3MDQ0NjY0Y2ZlOWZjNzU2NzBhNzI2YjY4OCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.28-5Elzs5t-rNIdV7KEUEtaKBSmWAjcy4LwWx2s7AKQ','2026-05-12 17:25:53.877932','2026-05-19 17:25:53',8,'e35fcd7044664cfe9fc75670a726b688');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (349,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI1OTQ3MywiaWF0IjoxNzc4NjU0NjczLCJqdGkiOiI5YjdmYzgxYWM0ZmM0OWZlYTNkOTIwNjA1NGQzNzc0MCIsInVzZXJfaWQiOiI4In0.f3M0VnbDq5mAaCq5ksWlqAY1SO65rz4nSRZa78gphqs','2026-05-13 06:44:33.225117','2026-05-20 06:44:33',8,'9b7fc81ac4fc49fea3d9206054d37740');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (350,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MDA4NiwiaWF0IjoxNzc4NjU1Mjg2LCJqdGkiOiIzODhmNzRlNWNkNzQ0NThmOTQ4ZjRlNjhiYmZkMTY1YyIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.SyJI4IbbhU16fK_L8nhp7oHDuneuE8GL8cCGvNxVtaU','2026-05-13 06:54:46.759946','2026-05-20 06:54:46',8,'388f74e5cd74458f948f4e68bbfd165c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (351,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MDA4NiwiaWF0IjoxNzc4NjU1Mjg2LCJqdGkiOiI2NzQ2NTQ4ZWYzMTA0YTNmYTRiYjZjMDUxMWVjZWQwMCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.j5N-kEOIAknPbtbnzjp9qqN9E3hTqhqhmubUCUIWUUQ','2026-05-13 06:54:46.844141','2026-05-20 06:54:46',8,'6746548ef3104a3fa4bb6c0511eced00');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (352,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MDY5NCwiaWF0IjoxNzc4NjU1ODk0LCJqdGkiOiIzZjk0ZDViYTUwNzk0NTAwOTg4YTBmY2NmZGY0NjI0ZSIsInVzZXJfaWQiOiI4In0.V6igRUpxAJiRKyd8uO-OPrknOBgx78MO8QW7Ax8CdXk','2026-05-13 07:04:54.353617','2026-05-20 07:04:54',8,'3f94d5ba50794500988a0fccfdf4624e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (353,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MDkzMiwiaWF0IjoxNzc4NjU2MTMyLCJqdGkiOiIyMWFjMDIxZDI0MWM0YjQ1YTFjYTYwZjE4YWJkM2ZjNiIsInVzZXJfaWQiOiIxIn0.ASRHHa1lJQKZLuc5p8ge3PplyndkOVGgGgA-efi2J40','2026-05-13 07:08:52.124030','2026-05-20 07:08:52',1,'21ac021d241c4b45a1ca60f18abd3fc6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (354,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTA0NywiaWF0IjoxNzc4NjU2MjQ3LCJqdGkiOiJhZjRhNTk0M2YwNTY0YTMxOTY2OTBjNzY2ZmM4MzliZSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.7fYFH9VaSHZkvjsMQ3gJVQF8_FdaWcGtrUvM4Munzkw','2026-05-13 07:10:47.097975','2026-05-20 07:10:47',1,'af4a5943f0564a3196690c766fc839be');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (355,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTA0NywiaWF0IjoxNzc4NjU2MjQ3LCJqdGkiOiIxN2YxZWRhZGVmM2M0NzMxYmRlMTI1MWM5NGE0ZjEyYSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.GfuwMQm-aL0BLQgKDM3619ubYg9i_ox3AqKvPL9_KHM','2026-05-13 07:10:47.109984','2026-05-20 07:10:47',1,'17f1edadef3c4731bde1251c94a4f12a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (356,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTE1MCwiaWF0IjoxNzc4NjU2MzUwLCJqdGkiOiJjNjBhNTAwNTNlNDY0OGU0YWRjNDYwMDIzZjc0MDllYSIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ.NIrWLyalISpENqm647UCOTRxR2jpN80QEOL3UivWT4E','2026-05-13 07:12:30.541627','2026-05-20 07:12:30',1,'c60a50053e4648e4adc460023f7409ea');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (357,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTE1MCwiaWF0IjoxNzc4NjU2MzUwLCJqdGkiOiIzMTAzYjllMDQyOTM0ZTE0OGVlNWRjNTgzOTU3YmRmNCIsInVzZXJfaWQiOiIxIiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJhZG1pbkBmdXJuaXNob3AubG9jYWwifQ._ltVTIZf-q1ScC4-ZtCqLc-s_acp15ytyuw2XLgB_14','2026-05-13 07:12:30.566330','2026-05-20 07:12:30',1,'3103b9e042934e148ee5dc583957bdf4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (358,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTIwNSwiaWF0IjoxNzc4NjU2NDA1LCJqdGkiOiI2MjEzNTU2ZDkzOTE0ODMwOTJlYjhmYTdjZDNhMTM2MiIsInVzZXJfaWQiOiIxMiJ9.6rUhxP_Zl--Ym-dQ0sUlRRwKcSTd9RxBlwyW88k_5x8','2026-05-13 07:13:25.116248','2026-05-20 07:13:25',12,'6213556d9391483092eb8fa7cd3a1362');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (359,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTI2OCwiaWF0IjoxNzc4NjU2NDY4LCJqdGkiOiIxMTY3MTMxYWNhMzQ0ZTI2Yjc5ZTkxNTBlMDU4OWY3MiIsInVzZXJfaWQiOiIxMiIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZnVybmlzaG9wLmxvY2FsIn0.MoxbnlqOCCx0hhbm8NnLuniVfEMdG4RIHTFhNJshi9M','2026-05-13 07:14:28.414576','2026-05-20 07:14:28',12,'1167131aca344e26b79e9150e0589f72');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (360,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTI2OCwiaWF0IjoxNzc4NjU2NDY4LCJqdGkiOiI0ZTlhYTUyNDAzZGQ0NzE5ODI2ODJkYWFhYjQwNmQ0YSIsInVzZXJfaWQiOiIxMiIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZnVybmlzaG9wLmxvY2FsIn0.oRufypkJCMDR8C8Egu8VBRnLlkQuySmOW13Y4SclGbQ','2026-05-13 07:14:28.398118','2026-05-20 07:14:28',12,'4e9aa52403dd471982682daaab406d4a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (361,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTgyMywiaWF0IjoxNzc4NjU3MDIzLCJqdGkiOiIyZTQ3MjYwZTBlNTA0MzBjYWIwOTFkNzc0NmNiM2MzNiIsInVzZXJfaWQiOiIxMiIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZnVybmlzaG9wLmxvY2FsIn0.H6767dZ8lH8KZ0OTjxzm0LvbTElRmvO4OAzNj40Egvk','2026-05-13 07:23:43.707485','2026-05-20 07:23:43',12,'2e47260e0e50430cab091d7746cb3c36');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (362,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2MTgyMywiaWF0IjoxNzc4NjU3MDIzLCJqdGkiOiI0NDExZmUwNmVlMTA0ODQwYTVhMWJmOGUyMjk1ZjIxZiIsInVzZXJfaWQiOiIxMiIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZnVybmlzaG9wLmxvY2FsIn0.Lpg6xFPkmL9-OB-btpWFtNCf4f24tTcXuVohQ5xeMMQ','2026-05-13 07:23:43.684775','2026-05-20 07:23:43',12,'4411fe06ee104840a5a1bf8e2295f21f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (363,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2Mzk2NCwiaWF0IjoxNzc4NjU5MTY0LCJqdGkiOiJkMDg3M2FiMGNkYWY0MDIyOTJiM2M5NzZjY2ViNjhiNCIsInVzZXJfaWQiOiIxMiIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZnVybmlzaG9wLmxvY2FsIn0.Uplptoxl30YRQ8LHhXLLghKue2ogYHsYDEuehYb8QHk','2026-05-13 07:59:24.047032','2026-05-20 07:59:24',12,'d0873ab0cdaf402292b3c976cceb68b4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (364,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2Mzk4NywiaWF0IjoxNzc4NjU5MTg3LCJqdGkiOiIxMTQ1YjgzZmQzYjI0OWM5OTU2NDNhM2Q3OTQxNDFmNCIsInVzZXJfaWQiOiIxMiIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJ0ZXN0LXVzZXJAZnVybmlzaG9wLmxvY2FsIn0.Y--Se32hjNpZqug8VTL4OycyfUMky74X1LUI5Rwr-a0','2026-05-13 07:59:47.953777','2026-05-20 07:59:47',12,'1145b83fd3b249c995643a3d794141f4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (365,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2NDU1NSwiaWF0IjoxNzc4NjU5NzU1LCJqdGkiOiI2OTUwZWU5NTU5YWQ0OTQyYTM5YjJiZmNhMjQ0MTYxZSIsInVzZXJfaWQiOiI2In0.n4gmbqg38V2BYr8XWE5TfLvP1XSIb17ewO1XmPpeX6s','2026-05-13 08:09:15.451832','2026-05-20 08:09:15',6,'6950ee9559ad4942a39b2bfca244161e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (366,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2NDU3MiwiaWF0IjoxNzc4NjU5NzcyLCJqdGkiOiIxMmU1NTIzNzZmNzM0OGE2ODI0MDJlMzRmNjc0YzAyOCIsInVzZXJfaWQiOiI4In0.K2PtaRONhISeC4IPKM-7Dp8bgwAujmkfv0ohTJnJKok','2026-05-13 08:09:32.748207','2026-05-20 08:09:32',8,'12e552376f7348a682402e34f674c028');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (367,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2NDY3MSwiaWF0IjoxNzc4NjU5ODcxLCJqdGkiOiIzYTgzY2NjZjNmNzA0MThiODNlODUxNDBjZWZkNTcxMyIsInVzZXJfaWQiOiI2In0.G0YiqqnpUOKrTPC_lLmgD4nsA20U1ePc-6ivBoG78bA','2026-05-13 08:11:11.840330','2026-05-20 08:11:11',6,'3a83cccf3f70418b83e85140cefd5713');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (368,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2NDg0MCwiaWF0IjoxNzc4NjYwMDQwLCJqdGkiOiIzMmU0ZjZkZTk2OTA0YmM0YmQ3ZTkzNzEwYmM3MTg0NyIsInVzZXJfaWQiOiI4In0.Qk6ewFW1ogvcRl0IjEKdIxfIUnMMEJBFdKKHjj1TQBY','2026-05-13 08:14:00.691096','2026-05-20 08:14:00',8,'32e4f6de96904bc4bd7e93710bc71847');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (369,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2NDkwMiwiaWF0IjoxNzc4NjYwMTAyLCJqdGkiOiI3MDY5MDIxNmU3NGQ0YzNhYWIxMzAwMThlMTU4NmFlMiIsInVzZXJfaWQiOiI3In0.QekoecFS-u0RWsZRKjxo1y0EVCD5xCUlW_z6k44wcwc','2026-05-13 08:15:02.617490','2026-05-20 08:15:02',7,'70690216e74d4c3aab130018e1586ae2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (370,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI2NDk2MiwiaWF0IjoxNzc4NjYwMTYyLCJqdGkiOiI0ODAwYzJlYjQ5NzY0ODljYmE3NjdjZGFiYzgwZjI2ZCIsInVzZXJfaWQiOiI2In0.o12axrQnVro0q-ru47VDOxDphR-fKLLOHDM_v40_v_A','2026-05-13 08:16:02.984730','2026-05-20 08:16:02',6,'4800c2eb4976489cba767cdabc80f26d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (371,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3NTQ2MiwiaWF0IjoxNzc4NjcwNjYyLCJqdGkiOiJlZTViYjFmMzc4NjM0ZGUzYmQyMmI4NDUwMmRmOGE3MiIsInVzZXJfaWQiOiI2In0.Jr45wPqgK5jk_qU_oOZYtGPlK-17TAp8IYvzKjGgGWc','2026-05-13 11:11:02.061559','2026-05-20 11:11:02',6,'ee5bb1f378634de3bd22b84502df8a72');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (372,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTA1OCwiaWF0IjoxNzc4Njc0MjU4LCJqdGkiOiJlM2I2MzA3ZTdiODY0N2Y4ODExNDYzNTYzMDYxMzQ2ZiIsInVzZXJfaWQiOiI2In0.satdNtNBBgfrxube8h4y2phzqCvxG5LdK9uWwAQgj58','2026-05-13 12:10:58.816170','2026-05-20 12:10:58',6,'e3b6307e7b8647f8811463563061346f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (373,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTQ5MCwiaWF0IjoxNzc4Njc0NjkwLCJqdGkiOiJmMzljZmE1OWZiNWU0ZjM4Yjc5YmY1OGRkMjM4NWRjYiIsInVzZXJfaWQiOiI3In0.s3-d2hhDTNtufBNd239XKze5T2qlhEUHk3nf4pD0Tso','2026-05-13 12:18:10.618541','2026-05-20 12:18:10',7,'f39cfa59fb5e4f38b79bf58dd2385dcb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (374,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTUyOCwiaWF0IjoxNzc4Njc0NzI4LCJqdGkiOiIwNGRkMTFiYWI1Yjg0YjFhYTI3ZGVjMmFkMjlkZjFmZSIsInVzZXJfaWQiOiI2In0.dmRPMSd0qVqnKWW9sn29PO8pgJ-laO9GNwixjFVquI0','2026-05-13 12:18:48.240525','2026-05-20 12:18:48',6,'04dd11bab5b84b1aa27dec2ad29df1fe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (375,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTU5OSwiaWF0IjoxNzc4Njc0Nzk5LCJqdGkiOiJiNDE1NTU2ZjE1MDc0YjAwYTliODliNGY4YWYwM2U2MiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.1cJHIREDGPHRu9kdDpDpOMcXdYl8J1pp7eSceSjmXfE','2026-05-13 12:19:59.095402','2026-05-20 12:19:59',6,'b415556f15074b00a9b89b4f8af03e62');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (376,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTYxNCwiaWF0IjoxNzc4Njc0ODE0LCJqdGkiOiIwNWIxOGYwYmM2MTc0MjE2OTQ0MWQ3YjUzODA1Y2MwNyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.ud9XcOSAJC0G12x2FiPFvOUSw_D6H3DoDEJTxLR0txg','2026-05-13 12:20:14.001023','2026-05-20 12:20:14',6,'05b18f0bc61742169441d7b53805cc07');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (377,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTc0MSwiaWF0IjoxNzc4Njc0OTQxLCJqdGkiOiI1N2ZmNDdlNzQ4OTc0YmYzOGU1MjFmNGIxNjhiM2U3YyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.zW4mL-7tEt9cIg5SZ2wKVfT2e2GOKq6Qff6pYGkhlFo','2026-05-13 12:22:21.606335','2026-05-20 12:22:21',6,'57ff47e748974bf38e521f4b168b3e7c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (378,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTc1MCwiaWF0IjoxNzc4Njc0OTUwLCJqdGkiOiI3NWExYmUyYTkzN2E0YThiYjlhNzgyNjIzN2UwZDU4YSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.2SiJC00SOjUNVTiJagoZ7EpAAbJRAi4-Ei1iOC9kaSY','2026-05-13 12:22:30.495425','2026-05-20 12:22:30',6,'75a1be2a937a4a8bb9a7826237e0d58a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (379,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI3OTc2OCwiaWF0IjoxNzc4Njc0OTY4LCJqdGkiOiIwMzU2ODljZTcyYzc0NWNjYmIwZjlhYzdlYzE5M2RiNiIsInVzZXJfaWQiOiI4In0.fxWK_xcQBXS5e6eT_hqmkphc3uvZdMMZ_NJfFyFMIgk','2026-05-13 12:22:48.191028','2026-05-20 12:22:48',8,'035689ce72c745ccbb0f9ac7ec193db6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (380,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDAyNCwiaWF0IjoxNzc4Njc1MjI0LCJqdGkiOiJiZGE4N2Q0OTE0NTY0YWRjYmIxMDQzNzE1ODhhMGVhOSIsInVzZXJfaWQiOiI2In0.Dkyggq4oNswM1fWlVirAOvPW0GLIC4m9aH4dUHjnEYI','2026-05-13 12:27:04.241191','2026-05-20 12:27:04',6,'bda87d4914564adcbb104371588a0ea9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (381,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDE4MSwiaWF0IjoxNzc4Njc1MzgxLCJqdGkiOiIwMjA1M2E4ODFmNDc0YjVlOTM5NGI3YTYwM2M1ZmU1NSIsInVzZXJfaWQiOiI2In0.-GmgQL-fHnYaJ8MMxcmEuubYPjq-aIx0nm44TX0twOs','2026-05-13 12:29:41.595085','2026-05-20 12:29:41',6,'02053a881f474b5e9394b7a603c5fe55');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (382,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDM4OCwiaWF0IjoxNzc4Njc1NTg4LCJqdGkiOiI1MDcyNDRhMjk0MTg0MDUwODU4MTc4MGI1NDU0YzkwMSIsInVzZXJfaWQiOiI2In0.NcLHt6R1RWbfVux7JExxKW6JoGGDcg2IPFJ3RRfVtR8','2026-05-13 12:33:08.528495','2026-05-20 12:33:08',6,'507244a2941840508581780b5454c901');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (383,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDYxMywiaWF0IjoxNzc4Njc1ODEzLCJqdGkiOiJhNjliYzg3NmQyMzg0M2UxOTk4ODlmZWI3Njk0MjAxYSIsInVzZXJfaWQiOiI2In0.VFguGC9rCAeAbqFM7AHNCMcz8vZrM8pVMS0U807MF-Q','2026-05-13 12:36:53.143678','2026-05-20 12:36:53',6,'a69bc876d23843e199889feb7694201a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (384,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDYxNCwiaWF0IjoxNzc4Njc1ODE0LCJqdGkiOiIxMzExOGMyMDBhMDk0MTJlOWI5MzVlMTBkNGNlM2FkZSIsInVzZXJfaWQiOiI4In0.8vtPFwgw8k4Y1GgqD7Wk2vcTmEPT8WK47Kk1SJ2lygY','2026-05-13 12:36:54.848862','2026-05-20 12:36:54',8,'13118c200a09412e9b935e10d4ce3ade');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (385,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDczMiwiaWF0IjoxNzc4Njc1OTMyLCJqdGkiOiIxMDhhOTc2MzRhMTA0NWRjOTA5YTkwYTk5NzQwMDcwYiIsInVzZXJfaWQiOiI2In0.TTBAwQ7m0gEMFIeUJv6Bj-mxf9wpqR7xxV1laN2OFFE','2026-05-13 12:38:52.944686','2026-05-20 12:38:52',6,'108a97634a1045dc909a90a99740070b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (386,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDc0MSwiaWF0IjoxNzc4Njc1OTQxLCJqdGkiOiJlODM4ZTcxYzNjZTU0M2M4OGU2MjAwMzVhM2VjOGVlMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.pRikfso-gXhq_8Kp7i22Xu-CY4Ztj9-AgtKZX5nzMN0','2026-05-13 12:39:01.412622','2026-05-20 12:39:01',6,'e838e71c3ce543c88e620035a3ec8ee0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (387,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDc3NiwiaWF0IjoxNzc4Njc1OTc2LCJqdGkiOiJlYTAxODdkYzUzODM0NmJmYjdlZDIwNmFiMDcxZjRjNyIsInVzZXJfaWQiOiI4In0.ruJgfdBnAklTGsA3ZDA8vUul_m1c5_1v_s-IWOZs40I','2026-05-13 12:39:36.548862','2026-05-20 12:39:36',8,'ea0187dc538346bfb7ed206ab071f4c7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (388,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDkzMywiaWF0IjoxNzc4Njc2MTMzLCJqdGkiOiI3YTU5YTdkN2M0YzQ0YzcwYTUzOGFlZTc2MjMyNzNlNCIsInVzZXJfaWQiOiI3In0.-EYZ0Td2kAN2CmoENa9Ps8jDMxeNkC4IhuBjiRDMxpw','2026-05-13 12:42:13.630530','2026-05-20 12:42:13',7,'7a59a7d7c4c44c70a538aee7623273e4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (389,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MDk4NSwiaWF0IjoxNzc4Njc2MTg1LCJqdGkiOiIwZWI5NzQ2NDI2NmY0YTkzOWUyMjkyODcyMjU2MThiZSIsInVzZXJfaWQiOiI2In0.NxhM_zBQ7pOMQEX_ULZFWfVmQkBJfj_dq-JE0VXIQLI','2026-05-13 12:43:05.009775','2026-05-20 12:43:05',6,'0eb97464266f4a939e229287225618be');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (390,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MjI1NSwiaWF0IjoxNzc4Njc3NDU1LCJqdGkiOiI1OTNhMGI4OWE4YmI0YmNhYmJjODU4NzE1Y2Q2OTJjNiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Al9Skx21KWw0wrNUX2QmWVAL4jKxgWl9Bf4gIj0hu6I','2026-05-13 13:04:15.834076','2026-05-20 13:04:15',6,'593a0b89a8bb4bcabbc858715cd692c6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (391,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MjMwNSwiaWF0IjoxNzc4Njc3NTA1LCJqdGkiOiJmYzA0N2EzOTg0ZDc0NzE4YTRjOTU0ZjE4MzA3MTcyMyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.kQH7CwON-Az1xsVMdK1aVYyAVJLs6Qh7jv8VWqOL7DU','2026-05-13 13:05:05.620515','2026-05-20 13:05:05',6,'fc047a3984d74718a4c954f183071723');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (392,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MjQyNiwiaWF0IjoxNzc4Njc3NjI2LCJqdGkiOiJiYTE0YWFhN2E3OGM0MzJhODZkODA0MmIyN2JlZWZiYSIsInVzZXJfaWQiOiI2In0.LKRDVE_M4ToCUv5ge4dDecC7GOsnkZ0RAVcu5wMmYNk','2026-05-13 13:07:06.391539','2026-05-20 13:07:06',6,'ba14aaa7a78c432a86d8042b27beefba');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (393,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MjkzNCwiaWF0IjoxNzc4Njc4MTM0LCJqdGkiOiI0OTkzNTdiMmZmZWU0M2Q2OTZhOTMzZTJhMDFjMTcyOCIsInVzZXJfaWQiOiI4In0.jP0ZwS6pX_II8Pg729m1DgyWdpYFXIPgrqsGd4fwK90','2026-05-13 13:15:34.655554','2026-05-20 13:15:34',8,'499357b2ffee43d696a933e2a01c1728');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (394,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MjkzNiwiaWF0IjoxNzc4Njc4MTM2LCJqdGkiOiI4MmE5MGI2YzQ4NDM0NTQxYjVhZTBmZDYyYzNkODVkOCIsInVzZXJfaWQiOiI2In0.VhiNzKgBKbf5tIa8uau3E8rrqG5PPl40epN2wWc3hzg','2026-05-13 13:15:36.102877','2026-05-20 13:15:36',6,'82a90b6c48434541b5ae0fd62c3d85d8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (395,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4Mjk4OCwiaWF0IjoxNzc4Njc4MTg4LCJqdGkiOiI1ZjViZjFhNjE0ZjQ0ODc5ODA2OGRhODk1MTM4YTMzMyIsInVzZXJfaWQiOiI4In0.8p5TBHwt7k0DGB64Zz2rq01Cxzkh-Uf95TAJBj266WQ','2026-05-13 13:16:28.756419','2026-05-20 13:16:28',8,'5f5bf1a614f448798068da895138a333');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (396,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4MzEyMiwiaWF0IjoxNzc4Njc4MzIyLCJqdGkiOiJlZGI3NGEzOTk3ZmY0Njk4ODBhOGQ0NGZiMDZlNWY0OSIsInVzZXJfaWQiOiI4In0.l0qrPdofpO9gIDVQOTAlJqTYz4adjUQ0B33hrLveOvA','2026-05-13 13:18:42.760905','2026-05-20 13:18:42',8,'edb74a3997ff469880a8d44fb06e5f49');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (397,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4Mzc3NSwiaWF0IjoxNzc4Njc4OTc1LCJqdGkiOiIxYjBkNzJiZGUxNTc0MjdjODIzNzJjYWQyMzBjYmI2YiIsInVzZXJfaWQiOiI4In0.jofVHA8DGVFI4jN61yFx5WMxs2zmYOXzXoeXYlpFwLE','2026-05-13 13:29:35.142976','2026-05-20 13:29:35',8,'1b0d72bde157427c82372cad230cbb6b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (398,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4Mzg3NSwiaWF0IjoxNzc4Njc5MDc1LCJqdGkiOiJmMjMzZGE2YTA5OTg0OTQ3OTAxNWVjODgyODQ5MWNlYyIsInVzZXJfaWQiOiI4In0.g9SUXAnciEXY6w_QT5a6QltZBINHbUF5_id-CeSkedg','2026-05-13 13:31:15.554373','2026-05-20 13:31:15',8,'f233da6a099849479015ec8828491cec');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (399,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4Mzk3MywiaWF0IjoxNzc4Njc5MTczLCJqdGkiOiI1NDdjMWJkYmFhNWY0NDA2ODg2MGE4Mzk5YjVhNGNmNSIsInVzZXJfaWQiOiI3In0.1PUx1BurqZzwRAFiym2irLlEF-z1PtZ-MQpBtx5kkag','2026-05-13 13:32:53.120598','2026-05-20 13:32:53',7,'547c1bdbaa5f44068860a8399b5a4cf5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (400,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4Mzk3NSwiaWF0IjoxNzc4Njc5MTc1LCJqdGkiOiJmZGQ4OTU5MzczZDk0NDIxODE1MDg3YjM4OTY2MThkZSIsInVzZXJfaWQiOiI2In0.LaypSUEYh2pMv7Oq9havf2FkahW_MAt-ZmOUQx_UlLE','2026-05-13 13:32:55.220072','2026-05-20 13:32:55',6,'fdd8959373d94421815087b3896618de');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (401,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NTA4OSwiaWF0IjoxNzc4NjgwMjg5LCJqdGkiOiJhOGQ1NmQwMWRjNTc0ZTgwODY3OWI4ZWQ1MWE3NzNjOCIsInVzZXJfaWQiOiI2In0.KngxhUqCreIw3V0oI_b-Ac0nYmzogKRIHsp1-9k35DE','2026-05-13 13:51:29.121455','2026-05-20 13:51:29',6,'a8d56d01dc574e808679b8ed51a773c8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (402,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NTEyMSwiaWF0IjoxNzc4NjgwMzIxLCJqdGkiOiIxNGQ2ZWU5ZDQzNjU0YmIzYjY0NDhjNmFmMWM4YTdjOSIsInVzZXJfaWQiOiI4In0.kzDFqj1RN2G8E0isVO7hFI_oTAaaNZiYqxIlwkaVC3U','2026-05-13 13:52:01.286482','2026-05-20 13:52:01',8,'14d6ee9d43654bb3b6448c6af1c8a7c9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (403,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NTE3MCwiaWF0IjoxNzc4NjgwMzcwLCJqdGkiOiJiYmZhMDA2OGQ3MDI0N2E3YWM4ZWQwN2Q1ZDE4ODcwMiIsInVzZXJfaWQiOiI3In0.mpdxvH0JHGc6F2lwuTp-SprWdYkL0PyMytIE1si8i8w','2026-05-13 13:52:50.542230','2026-05-20 13:52:50',7,'bbfa0068d70247a7ac8ed07d5d188702');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (404,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NTUwMSwiaWF0IjoxNzc4NjgwNzAxLCJqdGkiOiJlMWMzMjA0NTlhNGM0ZDkxYWZhODA2NzMwYjAwOTUxNCIsInVzZXJfaWQiOiI2In0.gsfJNdoEqKSkVX68sVj7TfxHzvX80_zv7Zq8IVX3Sog','2026-05-13 13:58:21.502709','2026-05-20 13:58:21',6,'e1c320459a4c4d91afa806730b009514');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (405,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NTY0OSwiaWF0IjoxNzc4NjgwODQ5LCJqdGkiOiI4YTEzMTk1MjA4OWI0MTFmYWU0ZTc0ZmYxYjIyZjY5OCIsInVzZXJfaWQiOiI2In0.PWkxZM3Xz4aa4fe68id9Gyh4TZT3iFwq9naF5wIiCaU','2026-05-13 14:00:49.107850','2026-05-20 14:00:49',6,'8a131952089b411fae4e74ff1b22f698');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (406,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NzA4MCwiaWF0IjoxNzc4NjgyMjgwLCJqdGkiOiJmMjBmYjdlNTU1MmM0MGE2OTE1MTFhNjVlNTgwMzQyZCIsInVzZXJfaWQiOiI3In0.-DjjEypUUfVcHym5GSvhcQ_lDqgDrsRmD26Su3CoI7w','2026-05-13 14:24:40.627574','2026-05-20 14:24:40',7,'f20fb7e5552c40a691511a65e580342d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (407,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NzE1NCwiaWF0IjoxNzc4NjgyMzU0LCJqdGkiOiIyN2Y3YmIwNWVkOWI0NzZlYTdiZWJlYzNmMWEyNTljOCIsInVzZXJfaWQiOiI4In0.A2kng0RtGnUtU4st8GqQL2AvnLpAK9USKXkoTpzkWTs','2026-05-13 14:25:54.585660','2026-05-20 14:25:54',8,'27f7bb05ed9b476ea7bebec3f1a259c8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (408,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4NzI0NCwiaWF0IjoxNzc4NjgyNDQ0LCJqdGkiOiIyZDdjOTBkMTY5OTQ0ZmRkOTQ2NDVmMDdkOGM1OThmZiIsInVzZXJfaWQiOiI2In0.ue4hN8f-tnipfHCjjglRQyfFXcklaxQn-tnMYm_OMzc','2026-05-13 14:27:24.492822','2026-05-20 14:27:24',6,'2d7c90d169944fdd94645f07d8c598ff');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (409,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4OTIzMSwiaWF0IjoxNzc4Njg0NDMxLCJqdGkiOiI4YzVmZTM4MTE3MDE0MDE4YThhMWM3Y2M2MDYyOWMxNyIsInVzZXJfaWQiOiI2In0.ePmkEWqKBld9Aoc2gHz1-g0VZ6MFOYml887J3FOBJ2g','2026-05-13 15:00:31.469479','2026-05-20 15:00:31',6,'8c5fe38117014018a8a1c7cc60629c17');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (410,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4OTI2OSwiaWF0IjoxNzc4Njg0NDY5LCJqdGkiOiI0YmZjYjQ0OGNkMTI0OTc2YmQwNWQzNTFmY2I0MmYyYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Ezi5NYFeskwyEQqR-MV868tgKYNR_KQFDRc33LwCNn0','2026-05-13 15:01:09.759445','2026-05-20 15:01:09',6,'4bfcb448cd124976bd05d351fcb42f2a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (411,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4OTQ3NiwiaWF0IjoxNzc4Njg0Njc2LCJqdGkiOiJiNTJmMjc2YmI3MjM0MWE0YWYxODdkN2Y1ZmE1MDVmZSIsInVzZXJfaWQiOiI4In0.XLXS4P7UF1z7k0W2bFWfjOa74ZTw2FeX365ggSMBzKI','2026-05-13 15:04:36.762807','2026-05-20 15:04:36',8,'b52f276bb72341a4af187d7f5fa505fe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (412,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4OTgzOSwiaWF0IjoxNzc4Njg1MDM5LCJqdGkiOiIyNzlmOTUwYTY2MTQ0NjYwYTdjZmI5MWViNzUzYmNmMCIsInVzZXJfaWQiOiI3In0.CVxK2772FuYwPK1hJYXwR1ZIIIZcVRx-7tVE48XeTKM','2026-05-13 15:10:39.068954','2026-05-20 15:10:39',7,'279f950a66144660a7cfb91eb753bcf0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (413,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI4OTg0OSwiaWF0IjoxNzc4Njg1MDQ5LCJqdGkiOiI3ZDZjMGYzODlhY2E0ZmY1YWMwYWQ2MzRmZmI3YWE4YSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.3s6fkOlVJt12ra2KGr-bo2__g4anE7mK7RxqO3lEa1c','2026-05-13 15:10:49.036091','2026-05-20 15:10:49',7,'7d6c0f389aca4ff5ac0ad634ffb7aa8a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (414,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTMzNCwiaWF0IjoxNzc4Njg2NTM0LCJqdGkiOiJmMTlhNTJmY2ZkN2U0NWNlOTM0ZmE5MzcyMzVjODIwNyIsInVzZXJfaWQiOiI2In0.TNLFPlixagYkyl0leP62shEnw5I3hsHhv4g742xYRq4','2026-05-13 15:35:34.172269','2026-05-20 15:35:34',6,'f19a52fcfd7e45ce934fa937235c8207');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (415,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTM0NCwiaWF0IjoxNzc4Njg2NTQ0LCJqdGkiOiIwZDZjN2M2MTQwMTM0MWZiYTViMTE3ZmQzZGFhM2I0YiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.1domPkWoMxzwNzPO3Us210hgPkYObxxYxS03MF7G4FM','2026-05-13 15:35:44.253273','2026-05-20 15:35:44',6,'0d6c7c61401341fba5b117fd3daa3b4b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (416,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTQ2NCwiaWF0IjoxNzc4Njg2NjY0LCJqdGkiOiI3YWIzMmFiZDE3MDc0NDcyYmFlNjA3ZDQxOWQ2NzQ0NSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.OZKmgpaNypi-ls6IzSKLPh4XUBXpndHKHWZgnHf1rns','2026-05-13 15:37:44.007226','2026-05-20 15:37:44',6,'7ab32abd17074472bae607d419d67445');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (417,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTQ3OSwiaWF0IjoxNzc4Njg2Njc5LCJqdGkiOiJhMDdjYjlhMGE4NTA0ZDQwOWVkZDQwN2RkZWY5NzU1NiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.sWxdN3Qf_tELUcRXYZs3u3-aePgvs9UDUTp0BAeZ3zE','2026-05-13 15:37:59.753205','2026-05-20 15:37:59',6,'a07cb9a0a8504d409edd407ddef97556');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (418,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTUwMCwiaWF0IjoxNzc4Njg2NzAwLCJqdGkiOiI5MGVlNmU5YjdlN2U0Nzg5OGJjZTExZDdhZTZmYTZiMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.BWssjw-uHziwiClMtvT6WX4ndZ4BlQ7aigGyvReFw5c','2026-05-13 15:38:20.052037','2026-05-20 15:38:20',6,'90ee6e9b7e7e47898bce11d7ae6fa6b0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (419,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTUzMywiaWF0IjoxNzc4Njg2NzMzLCJqdGkiOiIyOTViZGJjMGM2OTk0YTk1YjE4ODU4M2Q3NzdlODAzZiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.ODoTmL-ANI2qromwG01QEVTRtmBWNZCROGvS_iYj3_Q','2026-05-13 15:38:53.941078','2026-05-20 15:38:53',6,'295bdbc0c6994a95b188583d777e803f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (420,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5MTU2NCwiaWF0IjoxNzc4Njg2NzY0LCJqdGkiOiI2ZjIzMzMzNWMxNTE0OGZkODYxZjA5YWVjN2JkMGZkNSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.w_ELpJ8h0ReyaXAP0YDJ1rh7lzpNXOCcbb5UhYwsmcU','2026-05-13 15:39:24.050627','2026-05-20 15:39:24',6,'6f233335c15148fd861f09aec7bd0fd5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (421,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTAxNiwiaWF0IjoxNzc4Njk0MjE2LCJqdGkiOiJiMzkwZjFlNzcxYTQ0NWE0YTJiMmU1NTIyODE0YjMzNiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.U6NSaUltwl_6CjqV-1Ffdaf5ViKyvSkirnFI2CV61IQ','2026-05-13 17:43:36.966627','2026-05-20 17:43:36',6,'b390f1e771a445a4a2b2e5522814b336');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (422,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTAzMiwiaWF0IjoxNzc4Njk0MjMyLCJqdGkiOiJmNjJiYzExOGQ1OGI0NTY2OTJhOTFjYzM3MmM2Y2VhOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.D1-xtA_yPLpbg5vo7zMwy6vSSeDdAcUVFTQIvcsu6kw','2026-05-13 17:43:52.699324','2026-05-20 17:43:52',6,'f62bc118d58b456692a91cc372c6cea9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (423,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTA1MCwiaWF0IjoxNzc4Njk0MjUwLCJqdGkiOiI1ODk4ZDFhMGJkYTQ0OTM2YWZhYjcwMmQzNDFkMjNhMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.CmTO5bYvVTPBjQLLXVdmrrPOp0EIn6wRVhgUqVR0HQw','2026-05-13 17:44:10.940678','2026-05-20 17:44:10',6,'5898d1a0bda44936afab702d341d23a0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (424,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTE0MCwiaWF0IjoxNzc4Njk0MzQwLCJqdGkiOiI0ZTVkMjUwNTIwZGU0ZDk1YmMyZjYzYTk3MzZiMzc0YyIsInVzZXJfaWQiOiI3In0.ier6PbjqYshuWWK1eLXWKiveOFYNeb-rSLSi7QlNEJo','2026-05-13 17:45:40.449533','2026-05-20 17:45:40',7,'4e5d250520de4d95bc2f63a9736b374c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (425,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTE0NSwiaWF0IjoxNzc4Njk0MzQ1LCJqdGkiOiI3NmFmY2Y0NjkwMDY0M2M3ODM3NGU4NDhjYjMzMjY1MiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.AZidMZH3IBkK190k1JTLY9WQc-mgx8u2Dcbtm_Eqj08','2026-05-13 17:45:45.288811','2026-05-20 17:45:45',7,'76afcf46900643c78374e848cb332652');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (426,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTE1NiwiaWF0IjoxNzc4Njk0MzU2LCJqdGkiOiJlZDJlN2NiZTAxY2Q0MmExODA3NTM5ZTVlMjQwNjE5YyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.vH7Za6zcO5XGEvq1RhoCU9SOobVNrPCPR-xvnpi37VA','2026-05-13 17:45:56.211546','2026-05-20 17:45:56',7,'ed2e7cbe01cd42a1807539e5e240619c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (427,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTI5OTE2NSwiaWF0IjoxNzc4Njk0MzY1LCJqdGkiOiJlYzhhMDRhZjEwZTM0ODhmYWM4ZjY1YjkwMzU0ZmVkNyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.BJ_vbOP-0AQmm6gSjK4zgWzXbm4o_4CHB9b4eg-Hlr4','2026-05-13 17:46:05.786383','2026-05-20 17:46:05',7,'ec8a04af10e3488fac8f65b90354fed7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (428,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM1OTM1NywiaWF0IjoxNzc4NzU0NTU3LCJqdGkiOiI5OWFlMjhjZDk1MmY0OGUzYTk2NWQ5NTc4YWVjNDMxMyIsInVzZXJfaWQiOiI3In0.qQE2mYUz1RwC_sNA-Nh2BuqVPBtUagNeeAtu0SEv6Sc','2026-05-14 10:29:17.111894','2026-05-21 10:29:17',7,'99ae28cd952f48e3a965d9578aec4313');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (429,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM1OTY2OCwiaWF0IjoxNzc4NzU0ODY4LCJqdGkiOiI4NDAyNjRiNDA2MTE0ODlkOTQ5NTM3ZGVhMzcwYzc2OSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.mJKG4JBRngGk5kuf4J80Fov09tcENYX9fyw7vVfVexQ','2026-05-14 10:34:28.584638','2026-05-21 10:34:28',7,'840264b40611489d949537dea370c769');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (430,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MDM2MCwiaWF0IjoxNzc4NzU1NTYwLCJqdGkiOiIzYTc3NDA4MTA1NmI0NDdkOGY1YmYzYzBlMWExM2YyOCIsInVzZXJfaWQiOiI4In0.VkNX13ohJCA11ZdQOv4tRxTEppd76BURGu5OQ8cBMco','2026-05-14 10:46:00.100495','2026-05-21 10:46:00',8,'3a774081056b447d8f5bf3c0e1a13f28');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (431,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MDQwNywiaWF0IjoxNzc4NzU1NjA3LCJqdGkiOiI4MDFiMjhjYjNmNmM0N2UzOTYzYzVjZTM1ZTg4N2RjOCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.iPXQyZC7xqIL2649F7U2hgMXsxp8my0KFHXW0pVY8r0','2026-05-14 10:46:47.987418','2026-05-21 10:46:47',8,'801b28cb3f6c47e3963c5ce35e887dc8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (432,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MDQ4MSwiaWF0IjoxNzc4NzU1NjgxLCJqdGkiOiJiNDZiZmZmNzgwN2E0ZWZhYTA1MzI1ZGU3YzlmNTZmZSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.obeesHFfaWG1Zh__SAl62gZuSIAIaY9ZQT8aAwWQAt0','2026-05-14 10:48:01.009607','2026-05-21 10:48:01',8,'b46bfff7807a4efaa05325de7c9f56fe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (433,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MTAzMywiaWF0IjoxNzc4NzU2MjMzLCJqdGkiOiIwOWU4OWY2Nzc5NzM0ZDBmYTUyZmQ0M2UyZDgzZDg3OCIsInVzZXJfaWQiOiI2In0.Pj9qih30P2VkucarJcKhnGRBm0emfGyrluLw_Ll2cHk','2026-05-14 10:57:13.557568','2026-05-21 10:57:13',6,'09e89f6779734d0fa52fd43e2d83d878');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (434,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MTE4NiwiaWF0IjoxNzc4NzU2Mzg2LCJqdGkiOiJjZTlkY2E0OTUzODY0OTU3YjBhNWI0ZjM5NzRhMDI4NCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.nfxhoiG8og7kkTppqhquJHe6C4n9NbgKR2v_-jfHqkA','2026-05-14 10:59:46.170077','2026-05-21 10:59:46',6,'ce9dca4953864957b0a5b4f3974a0284');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (435,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MTIxNSwiaWF0IjoxNzc4NzU2NDE1LCJqdGkiOiI1N2Y2MzE5YWFmNGM0ODk2OTkzZTVhMGViNjY3YTgxZiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.v7iuXVthcB2e_OMciAH3bxoJvj5YTY3cTpFnW7fz2U4','2026-05-14 11:00:15.998780','2026-05-21 11:00:15',6,'57f6319aaf4c4896993e5a0eb667a81f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (436,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MTY3NSwiaWF0IjoxNzc4NzU2ODc1LCJqdGkiOiI4ZDgzZmYwMDM1NWI0MjE5YjJkODQ0ODRmMzE5ZDVkMCIsInVzZXJfaWQiOiI2In0.J9UwPrsRmtZr21GUXZH9h6XEpJUwBTfOTrXOIdcQvzg','2026-05-14 11:07:55.213806','2026-05-21 11:07:55',6,'8d83ff00355b4219b2d84484f319d5d0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (437,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MjkzNCwiaWF0IjoxNzc4NzU4MTM0LCJqdGkiOiJlZWYyYmZmY2Y2OWE0ODM1ODZhYTU2NzIzZjJlOWUzOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.QQ0H8wKlNsmP75fYxFl1z9fo6jwrzsVv6RSLt1fPWPM','2026-05-14 11:28:54.293595','2026-05-21 11:28:54',6,'eef2bffcf69a483586aa56723f2e9e39');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (438,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzMyNywiaWF0IjoxNzc4NzU4NTI3LCJqdGkiOiI4NGMyZmMxOGZkZjk0OGYwYmI1YmEyZjYzMmQwZDQ1MSIsInVzZXJfaWQiOiI2In0.ofaDbJXMHgZCYo4ikFlkB32L39Q7tKgfc5BJR5vXKXk','2026-05-14 11:35:27.716797','2026-05-21 11:35:27',6,'84c2fc18fdf948f0bb5ba2f632d0d451');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (439,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzMzNCwiaWF0IjoxNzc4NzU4NTM0LCJqdGkiOiJkNzZjMzMyY2IzMzg0MjdkODA1ZjM2MDUzNzg0MmRhOCIsInVzZXJfaWQiOiI2In0.mF8NxAMEMvIEkCSMhuURMITeFQzQVBr4xXMPxQlxx20','2026-05-14 11:35:34.224166','2026-05-21 11:35:34',6,'d76c332cb338427d805f360537842da8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (440,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzM4OSwiaWF0IjoxNzc4NzU4NTg5LCJqdGkiOiIwOWMyMjE0YWQ4ZTk0YWI3YTJhN2I4YzY3MDViNjg2ZSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.WDuo7Hl-IZDmJ8NjVQmq2RmGQ2hQM0TdQFaQCIL_nls','2026-05-14 11:36:29.136190','2026-05-21 11:36:29',6,'09c2214ad8e94ab7a2a7b8c6705b686e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (441,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzQ0MCwiaWF0IjoxNzc4NzU4NjQwLCJqdGkiOiIzYWExZDI3YzEyOTA0YjAwODMzNjIwMzYxY2EwMzYzZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.SwvK4eI2ShJ300yn-Jvf2WLMzimP-yFDGer_2DP-orU','2026-05-14 11:37:20.175716','2026-05-21 11:37:20',6,'3aa1d27c12904b00833620361ca0363d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (442,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzQ4MiwiaWF0IjoxNzc4NzU4NjgyLCJqdGkiOiI3M2JhNzc0M2FjNWU0MWFhYmJmYWFlNTQzYTFmYzBmZSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.KFjpvJYmKtyZK3QSQWZYAj63qPiHkPZmFzwPMl_2FxM','2026-05-14 11:38:02.749430','2026-05-21 11:38:02',6,'73ba7743ac5e41aabbfaae543a1fc0fe');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (443,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzU4NSwiaWF0IjoxNzc4NzU4Nzg1LCJqdGkiOiJlOTJhZDViNmI0OGU0ZmZiOTA0OTZjZDA1NTRkZmMzNCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.-7zep9HAMJUnMsInb9YndNLG9O64JnOIAVD7k7qfPgo','2026-05-14 11:39:45.376150','2026-05-21 11:39:45',6,'e92ad5b6b48e4ffb90496cd0554dfc34');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (444,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2Mzc3NywiaWF0IjoxNzc4NzU4OTc3LCJqdGkiOiIwODUyZTlhMDZmYzQ0YjFjYmI0NTM1NmNjNzE5NWEyMSIsInVzZXJfaWQiOiI3In0.nJKLMWqtgTGWgN6f404p_ks2zd-PmWASyAZRT1ndrdI','2026-05-14 11:42:57.805348','2026-05-21 11:42:57',7,'0852e9a06fc44b1cbb45356cc7195a21');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (445,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2Mzg2NiwiaWF0IjoxNzc4NzU5MDY2LCJqdGkiOiI0ZjlkZDk4N2E1ZGU0MDMyOWNhMjk2NTk5ZjQ3M2I1NiIsInVzZXJfaWQiOiI2In0.pAA7MZ_cDe9rr9nCql4yDcmMGgfJk8jdyIe-6XVEfL4','2026-05-14 11:44:26.879414','2026-05-21 11:44:26',6,'4f9dd987a5de40329ca296599f473b56');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (446,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2MzkxMCwiaWF0IjoxNzc4NzU5MTEwLCJqdGkiOiI5ZWNmZWExMjczOGI0NzkxODY4OTlmOWQzODZiMzg4NSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.CM8OFJ9JmqgIIPqxo09CRU7hmOtnPMQUMHsyXj3yQJA','2026-05-14 11:45:10.060688','2026-05-21 11:45:10',6,'9ecfea12738b479186899f9d386b3885');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (447,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2NDExOSwiaWF0IjoxNzc4NzU5MzE5LCJqdGkiOiJlM2NlYzI1ZTFjZjA0NzUxYjRlZTczZDlmOWFlYjhhYyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.gZsLlFdLF-u8M9Oee2eK3dPkmFzzHbh8L8qGw99InzQ','2026-05-14 11:48:39.190279','2026-05-21 11:48:39',6,'e3cec25e1cf04751b4ee73d9f9aeb8ac');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (448,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2NDEyOSwiaWF0IjoxNzc4NzU5MzI5LCJqdGkiOiIzMmZkNmU3NzQ4OWQ0MTdmYTk1NDc5MzJhNDY5ZWU2MiIsInVzZXJfaWQiOiI4In0.6qSHy7qFVs-fIh9sKvh-s_j4OfupzB-H41cOpCOrsws','2026-05-14 11:48:49.441403','2026-05-21 11:48:49',8,'32fd6e77489d417fa9547932a469ee62');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (449,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM2NDE0NiwiaWF0IjoxNzc4NzU5MzQ2LCJqdGkiOiJkODQ5M2ZiMTQ3Yjc0OWIwYTg4Y2QwMzk1NTVhYmJiMSIsInVzZXJfaWQiOiI4In0.IkL9rg6MVBUfK03yr-o2-GECWJOtxuRvfy9Q1zoT6Oc','2026-05-14 11:49:06.496117','2026-05-21 11:49:06',8,'d8493fb147b749b0a88cd039555abbb1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (450,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM4MDA0NSwiaWF0IjoxNzc4Nzc1MjQ1LCJqdGkiOiIzMDEyY2Q4ZjcyYmI0Nzc4YjIzNTgyNmQ5ODI4OTc3OCIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.qcAn29pnXXfE_vONl6cxmzN1qnpNXt44tI-ATmzImPY','2026-05-14 16:14:05.842471','2026-05-21 16:14:05',8,'3012cd8f72bb4778b235826d98289778');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (451,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM4MDA1OSwiaWF0IjoxNzc4Nzc1MjU5LCJqdGkiOiJhNmNjMDdjNGViNmY0YzQyOWVkNjI1Y2FmZmY1N2MyZiIsInVzZXJfaWQiOiI2In0.Q7VdZD2eM8ytNieJM8BtSofxMFC8ubTaRL5hBZrs37E','2026-05-14 16:14:19.978577','2026-05-21 16:14:19',6,'a6cc07c4eb6f4c429ed625cafff57c2f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (452,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM4MTI3NiwiaWF0IjoxNzc4Nzc2NDc2LCJqdGkiOiIzMmFjN2EyMDUxOTc0NDAxODU3ZDQ4NDRjMjcwOTcxOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.9moKT67JrvpY5kR08Joo5FUuQzp796d6L58yajq4K-Y','2026-05-14 16:34:36.169917','2026-05-21 16:34:36',6,'32ac7a2051974401857d4844c2709719');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (453,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM4MjE3NSwiaWF0IjoxNzc4Nzc3Mzc1LCJqdGkiOiJmOTkwN2FkM2Q4ODk0MmZiODVmMWExNTExOTFkZDczZSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.sVB8PvcrcHpSxI73CtUu_W0psNygJRBtYPWLF4HJDEA','2026-05-14 16:49:35.088136','2026-05-21 16:49:35',6,'f9907ad3d88942fb85f1a151191dd73e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (454,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTM4ODA3MCwiaWF0IjoxNzc4NzgzMjcwLCJqdGkiOiI3OTQ0NTUwYjQ0YjM0ZjU0ODhmNWJhZGRkYjM2ZWNiNCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.xrMpwO-C0_gjO9qoZP-l8_Fx-Px7jvgJoitRwEp9lEA','2026-05-14 18:27:50.727062','2026-05-21 18:27:50',6,'7944550b44b34f5488f5badddb36ecb4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (455,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTQyMDYyMSwiaWF0IjoxNzc4ODE1ODIxLCJqdGkiOiIyM2U4M2FhNDhiNGI0YjdkODZjNDM1ZTc5YjM3MjhjNyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.lpAwL9jMR4E0AgPbdtL83fBx_V_wlj3rR3WGCXCAA6g','2026-05-15 03:30:21.839478','2026-05-22 03:30:21',6,'23e83aa48b4b4b7d86c435e79b3728c7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (456,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDI0NiwiaWF0IjoxNzc5MDg1NDQ2LCJqdGkiOiIxYTQ5NGU4NTJlYWY0NDVmYjc3ZWY1ZGNiN2E2ZWQwYSIsInVzZXJfaWQiOiI2In0.9k2ZWpcy_lz2kbNkNy4X_AD-rqXByXo20Qa8guffbRw','2026-05-18 06:24:06.977374','2026-05-25 06:24:06',6,'1a494e852eaf445fb77ef5dcb7a6ed0a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (457,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDQ3OCwiaWF0IjoxNzc5MDg1Njc4LCJqdGkiOiIyMDY3NDAzYmI3MmI0NWNjYTRiMWE4MDYwZGNiMzc2NCIsInVzZXJfaWQiOiI3In0.ZpLXrbwa_2LrlCfoCLwY5UDwB9o2NQGp54gFL3oxzjA','2026-05-18 06:27:58.487987','2026-05-25 06:27:58',7,'2067403bb72b45cca4b1a8060dcb3764');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (458,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDUyMywiaWF0IjoxNzc5MDg1NzIzLCJqdGkiOiJhNzk0MTEwMTE3NDM0MjA3YTAyMDdmZmMyZWU4YjNmMSIsInVzZXJfaWQiOiI2In0.mdb2auWYpTLzUgdZapj9VC3ts4JzOb0mJuIke-n-oUI','2026-05-18 06:28:43.707523','2026-05-25 06:28:43',6,'a794110117434207a0207ffc2ee8b3f1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (459,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDUyNCwiaWF0IjoxNzc5MDg1NzI0LCJqdGkiOiIwNzI1NTRiNGYyOGY0Mjk5ODA2YWVhZTBhY2FjMTA3NiIsInVzZXJfaWQiOiI2In0.kgVl_Kpxlevv97LJIgDVqs-zfsCKGFeWGI17WriKOV4','2026-05-18 06:28:44.285882','2026-05-25 06:28:44',6,'072554b4f28f4299806aeae0acac1076');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (460,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDU2MSwiaWF0IjoxNzc5MDg1NzYxLCJqdGkiOiIzMDA5ZGJjYjk1ZDY0ZjQwODFlMDA1OTkyMzBkODI4NyIsInVzZXJfaWQiOiI2In0.UckfLxIzNmcdM3aX1MKOjnjN2wYl2rlZIGTMrnOn3Ok','2026-05-18 06:29:21.052913','2026-05-25 06:29:21',6,'3009dbcb95d64f4081e00599230d8287');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (461,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDcxNCwiaWF0IjoxNzc5MDg1OTE0LCJqdGkiOiIyZjljNTQxNDZlZDE0YzIzYWMyOWI3NWI2NDRiMjE0OSIsInVzZXJfaWQiOiI2In0.sBp1EhrvLX3F-ayVTFap2TLCv8oW1JbW5jR_KO-hE9g','2026-05-18 06:31:54.822955','2026-05-25 06:31:54',6,'2f9c54146ed14c23ac29b75b644b2149');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (462,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDgzOSwiaWF0IjoxNzc5MDg2MDM5LCJqdGkiOiI2NjdlZmM4YzczNmI0NGJhYTZjYTNkZjc5OTA5Nzk3YyIsInVzZXJfaWQiOiI4In0.5n_INmCb8QKbvl75YSqBX7n_-aTMvEfkEPp2Q2M2UNc','2026-05-18 06:33:59.303532','2026-05-25 06:33:59',8,'667efc8c736b44baa6ca3df79909797c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (463,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDkyOCwiaWF0IjoxNzc5MDg2MTI4LCJqdGkiOiJlOWQxMmRkNGM0OTk0MTlmYTA2YTlmZGNlOWM4MDcwYiIsInVzZXJfaWQiOiI2In0.P8EPNdyZ-sVhHpMVmR-GkPnAQBz5WG3cYQSYWPfqq1Q','2026-05-18 06:35:28.674301','2026-05-25 06:35:28',6,'e9d12dd4c499419fa06a9fdce9c8070b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (464,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MDk2MCwiaWF0IjoxNzc5MDg2MTYwLCJqdGkiOiJkYjBkOTFjY2M5NGU0M2U4OGEzNzYwYjc0NjA2M2VhNyIsInVzZXJfaWQiOiI4In0.v73GAVdutjJIrQw2C1Jb-0ZkaDmayqNgQ9wVwKezR3I','2026-05-18 06:36:00.762799','2026-05-25 06:36:00',8,'db0d91ccc94e43e88a3760b746063ea7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (465,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MTE4NiwiaWF0IjoxNzc5MDg2Mzg2LCJqdGkiOiI5ODgyNTYwZWE5NWU0ZDhmOTVhZmRhMmZhYjI3NDVlMSIsInVzZXJfaWQiOiI2In0.TMUJg96qi952bnHni9pqIrI-2JaUeXeffe8gD49fPR0','2026-05-18 06:39:46.310577','2026-05-25 06:39:46',6,'9882560ea95e4d8f95afda2fab2745e1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (466,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5MTIzOSwiaWF0IjoxNzc5MDg2NDM5LCJqdGkiOiI3YzNiOTMzNTg0ODQ0ZGI0YWMyMTgwZDgwZjlmYjc2YSIsInVzZXJfaWQiOiI4In0.DXY6v99qmP_pCy9K-HKOnHidfac4Vb537vL2UOMnRh0','2026-05-18 06:40:39.925572','2026-05-25 06:40:39',8,'7c3b933584844db4ac2180d80f9fb76a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (467,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NjczOCwiaWF0IjoxNzc5MDkxOTM4LCJqdGkiOiJiMDg3YmIyNDA4N2Y0ZjgzODUzNTEzMTQ1YjM3OGYwOCIsInVzZXJfaWQiOiIxNCJ9.2-zsn-7crw9p2UXPzHc5kXCV2Gfrxac39O0FP0aiuiA','2026-05-18 08:12:18.539797','2026-05-25 08:12:18',14,'b087bb24087f4f83853513145b378f08');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (468,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5Njc4MCwiaWF0IjoxNzc5MDkxOTgwLCJqdGkiOiJiYzZmMmUzYTg0MmQ0ZmY3OWRlZTE4ODEyYWI0NmZhOCIsInVzZXJfaWQiOiIxNCJ9.2f6mMYzZovtTYuyQdb9M-_YQy1Y4p6te4HkTsfsOFD0','2026-05-18 08:13:00.055514','2026-05-25 08:13:00',14,'bc6f2e3a842d4ff79dee18812ab46fa8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (469,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5Njg3NCwiaWF0IjoxNzc5MDkyMDc0LCJqdGkiOiIxNDdhOTU5NmMyM2Q0ZWRjYTg3NDViZGY5NTFhMjE2ZSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.ov_jTdCZehx7WPKg3sY_icMAxSRkwYkrDoCjtF7IiOU','2026-05-18 08:14:34.230637','2026-05-25 08:14:34',8,'147a9596c23d4edca8745bdf951a216e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (470,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5Njg4NSwiaWF0IjoxNzc5MDkyMDg1LCJqdGkiOiJjMGQ0YjQyNTg3YjQ0Mzc1OGYzZTI2YmYwNGVmNTA0YyIsInVzZXJfaWQiOiI2In0.k014dN_BqctPY_7kiuGs9T53s2VrVx84yoaXHknxhwM','2026-05-18 08:14:45.075533','2026-05-25 08:14:45',6,'c0d4b42587b443758f3e26bf04ef504c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (471,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzI1NCwiaWF0IjoxNzc5MDkyNDU0LCJqdGkiOiJjYzE2MjdkNWQ3MDA0MzI4OTcyNzdkMDU3MzFlNWM5NyIsInVzZXJfaWQiOiI2In0._Fem3obgVavm8PohlkEnhw2FDPgfXecgogSMm1uZnak','2026-05-18 08:20:54.288163','2026-05-25 08:20:54',6,'cc1627d5d700432897277d05731e5c97');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (472,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzMxOSwiaWF0IjoxNzc5MDkyNTE5LCJqdGkiOiIyMGI5OGEyMjFlMjM0ZjYxYTQwOWQ0MjgwY2I1YzNkMyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.zbSe41daQK1SrsdGgPjiMmPY7wSvBzARXrkuTHq0TBg','2026-05-18 08:21:59.526490','2026-05-25 08:21:59',6,'20b98a221e234f61a409d4280cb5c3d3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (473,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzMyNSwiaWF0IjoxNzc5MDkyNTI1LCJqdGkiOiI2OWFmZDA0YWVkODU0MGRkOTdmYWYyYjYxZDk5MjNiYyIsInVzZXJfaWQiOiI2In0.uCMRhWOvp8gm0prsaXMQIPr_-hf_mf4-iQTxbbuiFuA','2026-05-18 08:22:05.424227','2026-05-25 08:22:05',6,'69afd04aed8540dd97faf2b61d9923bc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (474,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzM5OSwiaWF0IjoxNzc5MDkyNTk5LCJqdGkiOiI0MmQ1Mjk0OWY1ZWI0MjRjODJmMWUzYzMyYjAzYjE2YiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.KGKjJLjP5z64nQfGufzkC5sifHxThXq64k0es-3EiBI','2026-05-18 08:23:19.381101','2026-05-25 08:23:19',6,'42d52949f5eb424c82f1e3c32b03b16b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (475,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzQwMiwiaWF0IjoxNzc5MDkyNjAyLCJqdGkiOiIxYmVmODFiOThiNmQ0NjI1ODgxYjQzY2Y5NzE3ZDg0MSIsInVzZXJfaWQiOiIxNSJ9.t057MlhB7PuEhI59rIkuaCMPEq7nPPb3tEqQXOHWODA','2026-05-18 08:23:22.059057','2026-05-25 08:23:22',15,'1bef81b98b6d4625881b43cf9717d841');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (476,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzU1MSwiaWF0IjoxNzc5MDkyNzUxLCJqdGkiOiI1NTBhYjUzYjVjYzY0ZjJjYWE2NjA4ZjFlZDE3YmY0ZSIsInVzZXJfaWQiOiI2In0.rFqUGbpOaJfSkQISkdTaxkRpw0jCvGMPZvtNhCSmG9g','2026-05-18 08:25:51.479447','2026-05-25 08:25:51',6,'550ab53b5cc64f2caa6608f1ed17bf4e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (477,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5NzYyMiwiaWF0IjoxNzc5MDkyODIyLCJqdGkiOiIzMmY4Yzk1MTc1MmI0MDljYTc3YTgxNWUxOWFmOWNlNyIsInVzZXJfaWQiOiIxNSJ9.SBi7EdMMuqUURH0v8HzgKqyrUIOB7Xo18JoiyOA8D_g','2026-05-18 08:27:02.160681','2026-05-25 08:27:02',15,'32f8c951752b409ca77a815e19af9ce7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (478,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTY5Nzc1MSwiaWF0IjoxNzc5MDkyOTUxLCJqdGkiOiJhYTY0YjZkMWRmYmY0MGE4OTZlNDBkMTdjMzUwZWMwYSIsInVzZXJfaWQiOiI2In0.ys-uFSqM-rWLF-ubM-iDgPdu0Pxko_pPkSU2khgkcUA','2026-05-18 08:29:11.026856','2026-05-25 08:29:11',6,'aa64b6d1dfbf40a896e40d17c350ec0a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (479,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTcwMDEzNywiaWF0IjoxNzc5MDk1MzM3LCJqdGkiOiIyNTk0NGExMjUyMTk0NDk5ODdmOWQxNTZhNjE3OGEyNyIsInVzZXJfaWQiOiI2In0.3TrRJIjVRHX9t1O5odwS4waaWjy2IphxZTWLFS2WBmQ','2026-05-18 09:08:57.195144','2026-05-25 09:08:57',6,'25944a125219449987f9d156a6178a27');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (480,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTcwMTEyMiwiaWF0IjoxNzc5MDk2MzIyLCJqdGkiOiI2Yzc4MjA5NTYzM2I0YWI2YjUxZmU2ZTNmMGQ3MTUzNiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.KbLW3QA0XoXnzj1p_xU4usRpJBg-TisjHBbi8sIWACQ','2026-05-18 09:25:22.311573','2026-05-25 09:25:22',6,'6c782095633b4ab6b51fe6e3f0d71536');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (481,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTcwNTkxOSwiaWF0IjoxNzc5MTAxMTE5LCJqdGkiOiJkZWNmMzYzYjVjYTk0ZDhkOTIxNzE2ZTQ4ZTIzZTAyMSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.XR_xknoRTWhk2MRXEB9QpgKI2sXuI749qc5pfJZ0L0g','2026-05-18 10:45:19.473126','2026-05-25 10:45:19',6,'decf363b5ca94d8d921716e48e23e021');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (482,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc4MDY4NSwiaWF0IjoxNzc5MTc1ODg1LCJqdGkiOiJmYzJkMjk1YWJmYzI0MDI5OTgzMTkzZjM1M2E4MzY2MiIsInVzZXJfaWQiOiI2In0._nJPzVFoakAj-_WgxX48hn4M4hPXqSoicmrGODcUhYE','2026-05-19 07:31:25.191299','2026-05-26 07:31:25',6,'fc2d295abfc24029983193f353a83662');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (483,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc4MDc0OSwiaWF0IjoxNzc5MTc1OTQ5LCJqdGkiOiI4ZDdjODkzZTYzNWE0OTc0YjBjODdlYWMwZTkxMWMwOCIsInVzZXJfaWQiOiI2In0.cSqNzecetUk80rO2I_sggYzOpxXyjyQm8H0p8AZNJvg','2026-05-19 07:32:29.653051','2026-05-26 07:32:29',6,'8d7c893e635a4974b0c87eac0e911c08');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (484,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc4NDkyMiwiaWF0IjoxNzc5MTgwMTIyLCJqdGkiOiJhYWYxYjY1NzlhMWY0OGVhOTUyNjhiN2FhMmEwYTJhMyIsInVzZXJfaWQiOiI2In0.6JwMSgfqV-z2C--5g06D7jcKpz9KU7dJ2Y5IW666BKI','2026-05-19 08:42:02.490263','2026-05-26 08:42:02',6,'aaf1b6579a1f48ea95268b7aa2a0a2a3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (485,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc4NDkyNiwiaWF0IjoxNzc5MTgwMTI2LCJqdGkiOiI5OWFkY2YwOGFjMWQ0YWI5YTI0NDcwMGQ1YmYyYjRjZiIsInVzZXJfaWQiOiI3In0.yryK3IBU5kj6KHRQOgGIFAN05lgpJQo9K8wdLsnv874','2026-05-19 08:42:06.807241','2026-05-26 08:42:06',7,'99adcf08ac1d4ab9a244700d5bf2b4cf');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (486,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc4NTAzMSwiaWF0IjoxNzc5MTgwMjMxLCJqdGkiOiI2ODU2NDg3YWYyYzY0ZDczYjcwNmNjZmMyMTg1MjZkZSIsInVzZXJfaWQiOiI2In0.9KTjh4l4uGeztJOil5xZd0rvUm-jPks-CAx4szdYeBE','2026-05-19 08:43:51.561086','2026-05-26 08:43:51',6,'6856487af2c64d73b706ccfc218526de');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (487,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc5NTU4NywiaWF0IjoxNzc5MTkwNzg3LCJqdGkiOiIwMTA5OTk5ODQ2NTQ0OWEzODg5MGQwODE5MDMzZWUyYiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.1r6kVzOxu-xnVimAI-I0hwDPpgGwwRO21bI8wzVMMns','2026-05-19 11:39:47.353831','2026-05-26 11:39:47',6,'01099998465449a38890d0819033ee2b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (488,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTc5NTYzMCwiaWF0IjoxNzc5MTkwODMwLCJqdGkiOiIzNTdhNGM5MWZjYmU0ZWNmYTdlNGM3NDk2YzNjYzVhNSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.iVAAU57fkzSAiNEbXMypcj78UJY1axuCHxvORuxGoxA','2026-05-19 11:40:30.871038','2026-05-26 11:40:30',6,'357a4c91fcbe4ecfa7e4c7496c3cc5a5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (489,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTgwODE3MiwiaWF0IjoxNzc5MjAzMzcyLCJqdGkiOiI5YTg3MGI3NWIxY2Y0ZTFhYjlmNzU4YzRmZDI3ZjVmNSIsInVzZXJfaWQiOiI2In0.I3xpWDxiaJokxsxohS09gJcfWqhoxoLc8uuJ8D3zQ_Y','2026-05-19 15:09:32.531596','2026-05-26 15:09:32',6,'9a870b75b1cf4e1ab9f758c4fd27f5f5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (490,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc3OTg1OTk3NSwiaWF0IjoxNzc5MjU1MTc1LCJqdGkiOiI1ZGY2YjViZTM0YTM0NmRlOTRjOTk2NWZkOGU3YWY2OSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.LlrKJWOaaaB-RzHvdI5R6IOeovbcylBMP0kInYNWNt0','2026-05-20 05:32:55.905388','2026-05-27 05:32:55',6,'5df6b5be34a346de94c9965fd8e7af69');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (491,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDA2MzY4NiwiaWF0IjoxNzc5NDU4ODg2LCJqdGkiOiIyZmZkY2UzYzA3Y2Q0ZDQ5ODk3NGYwNjU2N2UyZTU1YSIsInVzZXJfaWQiOiIxNiJ9.OLmRekghn7Iq3AbauLjcSHXZoXWfQZMw61mSxjLmTp0','2026-05-22 14:08:06.287989','2026-05-29 14:08:06',NULL,'2ffdce3c07cd4d498974f06567e2e55a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (492,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjA2ODAyOCwiaWF0IjoxNzc5NDc2MDI4LCJqdGkiOiI5YzgzN2Y5MmRlYTg0MmM2OWJmOTgwNzczZWI2NTNjNSIsInVzZXJfaWQiOiI2In0.Rf7qwV_QS-21-dSNkO_Sev_ZN_lYewyXc4yy6J0X4wo','2026-05-22 18:53:48.638569','2026-06-21 18:53:48',6,'9c837f92dea842c69bf980773eb653c5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (493,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjA2ODk2NiwiaWF0IjoxNzc5NDc2OTY2LCJqdGkiOiI2MzI5OWIwM2U3YjA0ZGFhOTI1YTU4MzlkNjM4YTdkZSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Zxf7pw1oRRRS9o5SvALh5dii6NSaPXncLzQMygk0TOA','2026-05-22 19:09:26.591899','2026-06-21 19:09:26',6,'63299b03e7b04daa925a5839d638a7de');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (494,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjA5OTc5NiwiaWF0IjoxNzc5NTA3Nzk2LCJqdGkiOiIzMDExYjFmNDczN2U0MDZiOTk4YzliNjNjNzgyMmRjOCIsInVzZXJfaWQiOiI2In0.04-4aiz096_Bvhan6clVDWlbtjXzYVkAC0CFwi0gYLo','2026-05-23 03:43:16.532723','2026-06-22 03:43:16',6,'3011b1f4737e406b998c9b63c7822dc8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (495,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjA5OTgxMSwiaWF0IjoxNzc5NTA3ODExLCJqdGkiOiI4OTc4NTQ2Y2FlZjc0OGY0OGNjMmFmZGI0OTRiYWY0YiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.AWpUUhdTObes_CgqyzE5vg4nu6YgJf9l5SHhX4_kGLs','2026-05-23 03:43:31.569805','2026-06-22 03:43:31',6,'8978546caef748f48cc2afdb494baf4b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (496,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjA5OTk5OCwiaWF0IjoxNzc5NTA3OTk4LCJqdGkiOiIzYzIyNzJlZWI5MTc0NGM3ODMxZmUzNzQyNzlmZTQ5YyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.8SL_V0sP1i63p0HYIW9lEmTfwO9jqO2zD6boi09SC8s','2026-05-23 03:46:38.273366','2026-06-22 03:46:38',6,'3c2272eeb91744c7831fe374279fe49c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (497,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMDIyMiwiaWF0IjoxNzc5NTA4MjIyLCJqdGkiOiI5YWE0ZjhkZWUyZjQ0ODE4YTE4OTA2ZmY2ODQwY2UyNSIsInVzZXJfaWQiOiI2In0._56h8GDZ1hKqBihnqi3p_3XChe_E1gipF3Qeol8W0kw','2026-05-23 03:50:22.497915','2026-06-22 03:50:22',6,'9aa4f8dee2f44818a18906ff6840ce25');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (498,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMDgxMSwiaWF0IjoxNzc5NTA4ODExLCJqdGkiOiJlNzNiMzJmM2IyNWY0ODc1OGM5MjI2ZWRkZTk4ZWQ1OSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.TtMVwUaZy-sOLmRoTENMgjDE0vHv31kfKZ1mMDqYQYY','2026-05-23 04:00:11.757855','2026-06-22 04:00:11',6,'e73b32f3b25f48758c9226edde98ed59');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (499,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMTM5NSwiaWF0IjoxNzc5NTA5Mzk1LCJqdGkiOiIxZWU4ZTBjNzU3YWI0MzE3OWEwYWFmY2E1NWIwYmM3YSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.2flWX_-Y7yDkxlhrh5ECcw194mRwC4twZ7wqOmNOctY','2026-05-23 04:09:55.660768','2026-06-22 04:09:55',6,'1ee8e0c757ab43179a0aafca55b0bc7a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (500,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMTYzNywiaWF0IjoxNzc5NTA5NjM3LCJqdGkiOiJlODY3NWQ5MjZmMDk0MTY4OTZjZTZhMzNkZjRjNjczZSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.M3J1cFcX_fUaWjcaqPJ4ygEQUoN3JDW1pwYUtRBTKPc','2026-05-23 04:13:57.299241','2026-06-22 04:13:57',6,'e8675d926f09416896ce6a33df4c673e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (501,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMTgxOCwiaWF0IjoxNzc5NTA5ODE4LCJqdGkiOiI3ZjhjZmExZjA5YWQ0ODNmOGQ2ZTZkMTk3MGI0YzllMiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.dhGuX5t7fDOyojGJonUebME6s5KEPPVBk5XNVOBU0Hg','2026-05-23 04:16:58.630799','2026-06-22 04:16:58',6,'7f8cfa1f09ad483f8d6e6d1970b4c9e2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (502,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMTgxOCwiaWF0IjoxNzc5NTA5ODE4LCJqdGkiOiIyOGZjMmM3ZWVlZWU0NGFkOWUzNjU3YmM4YjA2OTBmNCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.YtdDWjFwO6R-ugIAdM4nyLIoLJHOc59sdgcs9EAfvQI','2026-05-23 04:16:58.639811','2026-06-22 04:16:58',6,'28fc2c7eeeee44ad9e3657bc8b0690f4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (503,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMTkwNywiaWF0IjoxNzc5NTA5OTA3LCJqdGkiOiJlZTNiOTdiMmRmZTA0NjljOTFlMjU4MWQyOWNhMzIyYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.QzHmrJdpYiXchyRWrXgUI_4TfxUKZmE1WNgy9QkVhYc','2026-05-23 04:18:27.594445','2026-06-22 04:18:27',6,'ee3b97b2dfe0469c91e2581d29ca322a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (504,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMjAyNSwiaWF0IjoxNzc5NTEwMDI1LCJqdGkiOiI5NmQ3OGYxM2U1ZjE0ZDAwYjNlNTkyNzFlMTZlZjQ1OSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.PF_kGmWLDcYNhwVCvf14bd5pwLME-hsGr5vbhv2m2ss','2026-05-23 04:20:25.024376','2026-06-22 04:20:25',6,'96d78f13e5f14d00b3e59271e16ef459');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (505,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMjcyMywiaWF0IjoxNzc5NTEwNzIzLCJqdGkiOiI0ZmVkYmY1ZDRmZjk0NjRiOTRlYmMzMTU1NmJhMzdlMyIsInVzZXJfaWQiOiI3In0.2PaKGJCiXgftCK4DfjH0DI0EjYg6gVkN2LnuoWBG9pk','2026-05-23 04:32:03.280496','2026-06-22 04:32:03',7,'4fedbf5d4ff9464b94ebc31556ba37e3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (506,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMjg1OSwiaWF0IjoxNzc5NTEwODU5LCJqdGkiOiI2ODAxNjM0YzA0Yzk0ZDBlYjgyNzMwNTNmZGUyMTQwNyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.Nga0ZRr-iv6rhVjIB1hSgZyoZZ1B4SCQoMRTVSE3KwA','2026-05-23 04:34:19.275797','2026-06-22 04:34:19',7,'6801634c04c94d0eb8273053fde21407');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (507,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEwMjg1OSwiaWF0IjoxNzc5NTEwODU5LCJqdGkiOiJjYmUwMjJiOGNmZjI0NzEyYjFkOWYyMWNlMDllMmVkYSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.jHS1CJ4dls1Mz4ALT4iIGX7u23l6tC8yulLzWYA5w2E','2026-05-23 04:34:19.204584','2026-06-22 04:34:19',7,'cbe022b8cff24712b1d9f21ce09e2eda');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (508,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDEyMjE0MCwiaWF0IjoxNzc5NTE3MzQwLCJqdGkiOiI5N2U5YmZhYWZmNzg0MzFhODZmNmQ3Y2EwYmRhZTk0ZSIsInVzZXJfaWQiOiI2In0.gRpR5_38gm3lwaroet2W5XbrLuPSWXRxZfwpmwV9w68','2026-05-23 06:22:20.908838','2026-05-30 06:22:20',6,'97e9bfaaff78431a86f6d7ca0bdae94e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (509,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyMDA4MSwiaWF0IjoxNzc5NTI4MDgxLCJqdGkiOiI1NTk2ODgxN2ZkNTg0YTdiODY3Njk4OTdjNTE0MDJjZCIsInVzZXJfaWQiOiI2In0.WzeylQJLIFL7NPO1CNcrvBO22QTFuDnuqNINw52Balw','2026-05-23 09:21:21.329768','2026-06-22 09:21:21',6,'55968817fd584a7b86769897c51402cd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (510,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyMDg2MywiaWF0IjoxNzc5NTI4ODYzLCJqdGkiOiI0NTE0ZDE3ZjEyNzg0YzhiYjM0MzUyNTJhMzEwNWQ4NyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.z0hSmATT8k9ooetzHMAlAtK9toWRJJBOyNmrJovXQhE','2026-05-23 09:34:23.376371','2026-06-22 09:34:23',6,'4514d17f12784c8bb3435252a3105d87');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (511,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNTIwOCwiaWF0IjoxNzc5NTMzMjA4LCJqdGkiOiI5Njg2MDMzN2M5ZGY0MzBmOWRjMjk2YzNjNzFkMGEyMyIsInVzZXJfaWQiOiI2In0.IIPpUee3PdowSlgOTH4jRaeG1EesE0WK02c8ppMXw_0','2026-05-23 10:46:48.048512','2026-06-22 10:46:48',6,'96860337c9df430f9dc296c3c71d0a23');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (512,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNTUxMiwiaWF0IjoxNzc5NTMzNTEyLCJqdGkiOiJlZmEzNTA5Y2U5ZTM0OTkxYjE5MDM3MTdjNDg0ZDRiMyIsInVzZXJfaWQiOiI3In0.PLztah-8u8yWOLsfigY-XNyAEUtxBmyMr_ghoQ03LmM','2026-05-23 10:51:52.365107','2026-06-22 10:51:52',7,'efa3509ce9e34991b1903717c484d4b3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (513,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNjE1MywiaWF0IjoxNzc5NTM0MTUzLCJqdGkiOiI5MzMzMDg2MjgxMzM0MDg5YWNhNjM4NGYzNzRhYzk4NSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.EfPbUBHOB1o2i8B8C65CGE6Y84r32hiVSKxMbxLW70M','2026-05-23 11:02:33.827626','2026-06-22 11:02:33',7,'9333086281334089aca6384f374ac985');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (514,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNjE4NCwiaWF0IjoxNzc5NTM0MTg0LCJqdGkiOiIwZTNjMGNhZmZlZjY0MzQ2YjZmOTlkYTk5YWYyZTNjYyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.7nsyl9Ua3p-FFpNUx4_oqUbWF7ldwKtB3vnUm5MD7_s','2026-05-23 11:03:04.325438','2026-06-22 11:03:04',7,'0e3c0caffef64346b6f99da99af2e3cc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (515,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNjcyOSwiaWF0IjoxNzc5NTM0NzI5LCJqdGkiOiJjMzdhNzQ2ZTBmYzk0NDUyOThjYmNiNDYxZWM2MWZkNSIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.jR1C4c4kY5ni3mLmiP504czKuhC_NrGJo4zGhwCuHK4','2026-05-23 11:12:09.053845','2026-06-22 11:12:09',7,'c37a746e0fc9445298cbcb461ec61fd5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (516,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNjcyOSwiaWF0IjoxNzc5NTM0NzI5LCJqdGkiOiJiZGEwZDNhYzUzYTI0MzhiYjQ3MDI1ZmY1N2JkZmExMyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.koZE1qxnz0TotL9l0YiSodgdw7wJB88yFdovEjfJqKE','2026-05-23 11:12:09.098838','2026-06-22 11:12:09',7,'bda0d3ac53a2438bb47025ff57bdfa13');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (517,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyNzk2MywiaWF0IjoxNzc5NTM1OTYzLCJqdGkiOiJlMTc1MzBkMmVhMzQ0OGYzYmU4NjI4Y2Q4MDFlNjIxNSIsInVzZXJfaWQiOiI2In0.gls8Qq8UXy6D71BHar4ZpbX_EW8236vRwlVk4473MB8','2026-05-23 11:32:43.796689','2026-06-22 11:32:43',6,'e17530d2ea3448f3be8628cd801e6215');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (518,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyODA3NCwiaWF0IjoxNzc5NTM2MDc0LCJqdGkiOiI3N2I4YTQzZDc2NzY0Y2E0ODAyNDYwYjdlNGQyOWU5ZiIsInVzZXJfaWQiOiI2In0.NR8AKvXmSt4jNUoWwLf4eeD_enSarwf3sREiohMvmRs','2026-05-23 11:34:34.413034','2026-06-22 11:34:34',6,'77b8a43d76764ca4802460b7e4d29e9f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (519,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyODM4MCwiaWF0IjoxNzc5NTM2MzgwLCJqdGkiOiI5NGVlY2U5Mjc1MjM0YjVmYTAxMmQwNDQyNzkzMjY4NiIsInVzZXJfaWQiOiI2In0.j0DmKB3LjqMKKZ35e3q6caMhzjZtBLq5Wj43mUCW-vk','2026-05-23 11:39:40.058731','2026-06-22 11:39:40',6,'94eece9275234b5fa012d04427932686');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (520,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyODQxMCwiaWF0IjoxNzc5NTM2NDEwLCJqdGkiOiI3ZjkxN2M3OGY1ZjY0OWUyODkwNmJmYWI2NDdiYzUxNyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.DgZR_tAEi_xz4_lGgd5dXTCw2crcbOKdPp95n3PTYnM','2026-05-23 11:40:10.207551','2026-06-22 11:40:10',6,'7f917c78f5f649e28906bfab647bc517');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (521,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEyODg0MSwiaWF0IjoxNzc5NTM2ODQxLCJqdGkiOiI2MGFlNmE1YjZjMDY0NzM0ODJhYjA3MWUzZTNkY2Y3MCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.aowO6wrAHCbNcVPyHSkmv9fAub2tYBrFuyrrLCZQ6b8','2026-05-23 11:47:21.064207','2026-06-22 11:47:21',6,'60ae6a5b6c06473482ab071e3e3dcf70');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (522,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzMzUxMiwiaWF0IjoxNzc5NTQxNTEyLCJqdGkiOiI5Yzk5MDVkNGUwY2Q0YmY2OTUwMTA4NzdmY2ViMzg0YyIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.-YcsV41TbA9sh00fLGwKVo2DNxK4B6qRy1cZ3bmoICM','2026-05-23 13:05:12.072074','2026-06-22 13:05:12',7,'9c9905d4e0cd4bf695010877fceb384c');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (523,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzMzUxMiwiaWF0IjoxNzc5NTQxNTEyLCJqdGkiOiJiMzQwMzhjZWIxYjM0NmEwYjNlYTk3Y2M2MmMzNGFkZCIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.-cDO1JePo6VLKXOEYa4EIMYNujwloOu7Dpwq4iWfXW8','2026-05-23 13:05:12.645517','2026-06-22 13:05:12',7,'b34038ceb1b346a0b3ea97cc62c34add');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (524,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzMzU4NSwiaWF0IjoxNzc5NTQxNTg1LCJqdGkiOiJjZTBhNTVlNDBkZGQ0ODQxYTJjNzZiNDkzZjIxMThhOSIsInVzZXJfaWQiOiI4In0.ej7sq-F2d3J_lO5L5LbajfNsE276MsD5UTPuFACmxI0','2026-05-23 13:06:25.954377','2026-06-22 13:06:25',8,'ce0a55e40ddd4841a2c76b493f2118a9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (525,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzMzYwMSwiaWF0IjoxNzc5NTQxNjAxLCJqdGkiOiIzOTVjOWMyZWM4NDA0Y2E1ODAxYjcwMDU0ZmI4MzQwZCIsInVzZXJfaWQiOiI4In0.ugY7zYu6sInOgzKyKoFbZWRzIO0V0ihVrqpSmNVCLYs','2026-05-23 13:06:41.342396','2026-06-22 13:06:41',8,'395c9c2ec8404ca5801b70054fb8340d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (526,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzMzYzNCwiaWF0IjoxNzc5NTQxNjM0LCJqdGkiOiIyNDNjYmQ1ZDk5MWY0MWUxYWNlMGJkMWIwNDZlZjk2NCIsInVzZXJfaWQiOiI4In0.NZuJdMFja-phvj-LsHKu-b7fM88qBDORwpoPrP42__E','2026-05-23 13:07:14.906577','2026-06-22 13:07:14',8,'243cbd5d991f41e1ace0bd1b046ef964');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (527,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzMzc3NSwiaWF0IjoxNzc5NTQxNzc1LCJqdGkiOiI1NGU3YzIyMmMwN2Q0ODgzOTA1OWQyYzY2MDMzODc1MCIsInVzZXJfaWQiOiI2In0.CiJXnLrRV7S97KfnjtXBjO1KFUjheBiV8UYkngz9Iko','2026-05-23 13:09:35.306043','2026-06-22 13:09:35',6,'54e7c222c07d48839059d2c660338750');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (528,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzNDQyNywiaWF0IjoxNzc5NTQyNDI3LCJqdGkiOiI4MmE5YmRkOGQxODI0NWUyOGRjMTM5YTk4N2VjMDRlNSIsInVzZXJfaWQiOiIxOSJ9.Y25TzEvtfkVUK5Hr8QCrxYunYebrHIXq7ygW-FdciYA','2026-05-23 13:20:27.210158','2026-06-22 13:20:27',19,'82a9bdd8d18245e28dc139a987ec04e5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (529,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjEzNDYwMSwiaWF0IjoxNzc5NTQyNjAxLCJqdGkiOiIyZDM5NTYzMjU3MzI0N2RkOTBhY2RlMzhjNzJkYmFlMCIsInVzZXJfaWQiOiI2In0.p2mAE9K5hfkt4BMZZUc6tmHVOTsjxyJpUGWd30ARWtM','2026-05-23 13:23:21.075685','2026-06-22 13:23:21',6,'2d395632573247dd90acde38c72dbae0');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (530,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE0NTg0OCwiaWF0IjoxNzc5NTUzODQ4LCJqdGkiOiJhYjg5M2MwMDNhMGY0YjdjYWI3OWNiMjQ2MGMxYWU2OCIsInVzZXJfaWQiOiI2In0.LJj0leq-f2ezlMIkFx0AUobmvXxmZ3ZOwx0F4FV-LQ0','2026-05-23 16:30:48.177189','2026-06-22 16:30:48',6,'ab893c003a0f4b7cab79cb2460c1ae68');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (531,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE0NjM2MiwiaWF0IjoxNzc5NTU0MzYyLCJqdGkiOiJlZDdmM2U0MGUzZDc0Y2E1OTA2OWU3ZDZhNDY0NmZkNyIsInVzZXJfaWQiOiI2In0.lE8Sdy9Ia-YGp3mqg2R5rHQuAZqKJoPrb-a0OU_GIxA','2026-05-23 16:39:22.988112','2026-06-22 16:39:22',6,'ed7f3e40e3d74ca59069e7d6a4646fd7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (532,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE0ODI0OSwiaWF0IjoxNzc5NTU2MjQ5LCJqdGkiOiIwZTZhOTcwODNhZWM0MmY5YTFhNmRlODdlZDZhMmIzOCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.jq8m0NTw-5QOS6_NXFTj3loQk6qNh7YRuU1jXAQOp-o','2026-05-23 17:10:49.809930','2026-06-22 17:10:49',6,'0e6a97083aec42f9a1a6de87ed6a2b38');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (533,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE1ODQ4MywiaWF0IjoxNzc5NTY2NDgzLCJqdGkiOiIxMWUyNGQ1ZGRkYTk0OWM0YjM4MWQyOWFiMTA3OWViOSIsInVzZXJfaWQiOiI2In0.RNMxbpfwfQ_drw7t_eHIu7i0SxW8khNsd-vAmywQXRI','2026-05-23 20:01:23.208891','2026-06-22 20:01:23',6,'11e24d5ddda949c4b381d29ab1079eb9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (534,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE1ODYzMiwiaWF0IjoxNzc5NTY2NjMyLCJqdGkiOiJhODU5MWU1NWY5Yjg0MTNkYTYxOTRkNjUzNDY1MTMwYiIsInVzZXJfaWQiOiI2In0.94OiWA449NQR9TT3_wWJ1k2YQkPmJs4HsOvAoYGieRs','2026-05-23 20:03:52.194331','2026-06-22 20:03:52',6,'a8591e55f9b8413da6194d653465130b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (535,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE1OTQzMCwiaWF0IjoxNzc5NTY3NDMwLCJqdGkiOiJkNTYwNTA1YWJjNDg0NGJlODRlMDE4Y2I0MTFkOWUxMCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.5vekKAjyE6qKU65w5hHaH9YtUVTk9duootqLkfqaMCw','2026-05-23 20:17:10.502773','2026-06-22 20:17:10',6,'d560505abc4844be84e018cb411d9e10');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (536,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE1OTQ5NSwiaWF0IjoxNzc5NTY3NDk1LCJqdGkiOiIyNGM4ODE0MGM4ZWM0YjJlODRhMjY4ZjM2NzdhNDQ4MyIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.LTaPa4MUL7RxACj-CP3GfxUtOTeY110kuAL-uGfBlnk','2026-05-23 20:18:15.299734','2026-06-22 20:18:15',6,'24c88140c8ec4b2e84a268f3677a4483');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (537,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE1OTYzNiwiaWF0IjoxNzc5NTY3NjM2LCJqdGkiOiI1YmJkMTg2M2E1ODM0ZDc1YTMxN2QzNzc4N2M2NTE0ZiIsInVzZXJfaWQiOiI2In0.-pTGOxHnoTUNMwSBfkrzJAGef9QyNWT7G7u6drpW1V4','2026-05-23 20:20:36.277405','2026-06-22 20:20:36',6,'5bbd1863a5834d75a317d37787c6514f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (538,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE2MTg5NSwiaWF0IjoxNzc5NTY5ODk1LCJqdGkiOiI3NGQ5MDUxNjVlNTQ0NmJiOTljNDkzNjAyMGZmZDU3MyIsInVzZXJfaWQiOiI2In0.VH1Z8TIZ2HCmHa1yVxfefDfcwuvPKa-XgYoqcYhBtww','2026-05-23 20:58:15.727977','2026-06-22 20:58:15',6,'74d905165e5446bb99c4936020ffd573');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (539,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE2MTkzOCwiaWF0IjoxNzc5NTY5OTM4LCJqdGkiOiJhNzFlZGJlMjE4NjY0YTU5YTJmNTAwNzA4NmJhYzM5YSIsInVzZXJfaWQiOiI4In0.MhDxCiOGmTwHkIVR9FLzvz9rVpv5dnM1EEGdrsJg4W4','2026-05-23 20:58:58.310802','2026-06-22 20:58:58',8,'a71edbe218664a59a2f5007086bac39a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (540,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4MTEyNCwiaWF0IjoxNzc5NTg5MTI0LCJqdGkiOiJlODc4OGNmOTRjNzM0NWI0ODJmYjAxMzRjNzg5MDQxMCIsInVzZXJfaWQiOiI2In0.yPoKkqnfC6T4TZaBYLm7w5-y9GZKZKQ67zTGlUTLkcg','2026-05-24 02:18:44.007990','2026-06-23 02:18:44',6,'e8788cf94c7345b482fb0134c7890410');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (541,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4MTE1NywiaWF0IjoxNzc5NTg5MTU3LCJqdGkiOiJmNzZmYjQ4ZTY4ZTk0ZmJlODk0Y2IzMDY4OWQ3ODAyMCIsInVzZXJfaWQiOiI2In0.oo6GljH-Q6qlvGgYQEXS4Y6KoFFV6xNPdW2suseeCGE','2026-05-24 02:19:17.705864','2026-06-23 02:19:17',6,'f76fb48e68e94fbe894cb30689d78020');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (542,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4MTI2MCwiaWF0IjoxNzc5NTg5MjYwLCJqdGkiOiI0MmIzMDFjYjliYjU0YzJiOWNlYjVlNDhiN2YyZWQzMiIsInVzZXJfaWQiOiI2In0.SLnS4hiaLx8fttXVdmi5KraL-UXLG8l6evQW4Kc7pnw','2026-05-24 02:21:00.131359','2026-06-23 02:21:00',6,'42b301cb9bb54c2b9ceb5e48b7f2ed32');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (543,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4MjE1MSwiaWF0IjoxNzc5NTkwMTUxLCJqdGkiOiI0ZTkwNWM5MTNhNjk0MmNjOTE0NjAxZjQ4Yzk3YzUxMyIsInVzZXJfaWQiOiI2In0.3YX-XY_11eRGkm9BAjIgTAeA23bi-3XkJxxih12o-8c','2026-05-24 02:35:51.410287','2026-06-23 02:35:51',6,'4e905c913a6942cc914601f48c97c513');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (544,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4MjQ1NiwiaWF0IjoxNzc5NTkwNDU2LCJqdGkiOiJlZGIzNzQyNTEyNjU0NTBhODc3YzJiZWE4ODJjOGM0MiIsInVzZXJfaWQiOiI3In0.gsj-rZZcXgQaHPDfTbQ2smfWkjPkSbBx-OGg775UmyM','2026-05-24 02:40:56.538921','2026-06-23 02:40:56',7,'edb374251265450a877c2bea882c8c42');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (545,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4MjYzNiwiaWF0IjoxNzc5NTkwNjM2LCJqdGkiOiJjY2QxOTY3NjYxZWE0NzU2OTk0MDAxOWMyNDg5NzczMCIsInVzZXJfaWQiOiI2In0.r7GcFJXZLSlxJOQqZNyMnrcOTNPzPGx4v43hh-YWnFc','2026-05-24 02:43:56.364923','2026-06-23 02:43:56',6,'ccd1967661ea47569940019c24897730');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (546,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NDMzMSwiaWF0IjoxNzc5NTkyMzMxLCJqdGkiOiI1NTNhODQwZWNjOGM0ZTNjYmY5YjQxYTA1OTk1OWYwMCIsInVzZXJfaWQiOiI2In0.3icExnuBQWlnjhtV1irGoZ2vDnFlCYMPe4002MPXhXQ','2026-05-24 03:12:11.742048','2026-06-23 03:12:11',6,'553a840ecc8c4e3cbf9b41a059959f00');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (547,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NDQzNCwiaWF0IjoxNzc5NTkyNDM0LCJqdGkiOiI5OTViZjdlYmVjMTk0YzQyYTIyM2Y4MjQ3YjliZDQyNiIsInVzZXJfaWQiOiIyMCJ9.aNAKdn6A2Q49caCuSJ-Iyd9Fstc5LzutQyMeF6Haw1U','2026-05-24 03:13:54.786257','2026-06-23 03:13:54',20,'995bf7ebec194c42a223f8247b9bd426');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (548,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NDkzNSwiaWF0IjoxNzc5NTkyOTM1LCJqdGkiOiIyMTJhYzcyNzRjOWU0YzM4ODdjNDM2NWY2N2Q3ZDNiNiIsInVzZXJfaWQiOiI2In0.4YvbqEXy3igjrauiT6a7Gn6joabNEISu76P-FLRz2Qc','2026-05-24 03:22:15.128387','2026-06-23 03:22:15',6,'212ac7274c9e4c3887c4365f67d7d3b6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (549,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NTI4MiwiaWF0IjoxNzc5NTkzMjgyLCJqdGkiOiJjYWZjZDIwOTk3ZDI0YzZlODNmNWFmZTE0ODNiNWEyMSIsInVzZXJfaWQiOiI2In0.8wTfnj3z-qrkarcIGPgFl-c6EkawC77ll-MCmr4veSQ','2026-05-24 03:28:02.159535','2026-06-23 03:28:02',6,'cafcd20997d24c6e83f5afe1483b5a21');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (550,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NTMwMiwiaWF0IjoxNzc5NTkzMzAyLCJqdGkiOiJkM2E4MjA2ZGI4OGI0NGE2OTczOGIyMzZlYzM3Njk2ZSIsInVzZXJfaWQiOiI2In0.1xyBCIm7gKmjEPTRthZK10V6-94tSaFnX2zzciiOCvs','2026-05-24 03:28:22.185952','2026-06-23 03:28:22',6,'d3a8206db88b44a69738b236ec37696e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (551,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NjYwMywiaWF0IjoxNzc5NTk0NjAzLCJqdGkiOiI1ODk1MmM1OWFkYzk0N2IzYTI0MjM3NGY2MzM0YTk4ZSIsInVzZXJfaWQiOiI4In0.kd3_uOsC_gKAl2wLSyUllrJFSnc3PJTOZjRlnVNJpDQ','2026-05-24 03:50:03.094057','2026-06-23 03:50:03',8,'58952c59adc947b3a242374f6334a98e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (552,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NzUyNCwiaWF0IjoxNzc5NTk1NTI0LCJqdGkiOiIyNDIyNWE1NTVjOGI0NWM2YTdmOTNlNTY0ZDYxYmE2NCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.9DEBtB17a8tGEwbu9VOyO-JQS68WvX7WJJpUuwum37g','2026-05-24 04:05:24.840307','2026-06-23 04:05:24',6,'24225a555c8b45c6a7f93e564d61ba64');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (553,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE4NzYxNywiaWF0IjoxNzc5NTk1NjE3LCJqdGkiOiIxNWM0ZTYxZmExOTU0YjYxYTc3ZWI1OTFjOWVmYWU4MSIsInVzZXJfaWQiOiI4In0.tU3Tb84OENdRoSy2m-wSai-7WJGmACNmSt4P2-zUW9E','2026-05-24 04:06:57.469010','2026-06-23 04:06:57',8,'15c4e61fa1954b61a77eb591c9efae81');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (554,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE5MjgxNCwiaWF0IjoxNzc5NjAwODE0LCJqdGkiOiI3MzIyODExMjQzODA0ZjM2YTYxMDQzMDBkNDgzNmNjZSIsInVzZXJfaWQiOiI3In0.MEKQgmlw22oAzij-qqiGhwsl_GRu6FkKbBp4v65nXzU','2026-05-24 05:33:34.289077','2026-06-23 05:33:34',7,'7322811243804f36a6104300d4836cce');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (555,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE5MzY3NiwiaWF0IjoxNzc5NjAxNjc2LCJqdGkiOiJmNGQ0NGYxMzU3OTI0NTE5ODMwNmMxOTgzMjkzY2IzNiIsInVzZXJfaWQiOiI4In0.BPcPyCHhz3vIrHqYCbmTMOtXGWsWZSNYTAmhm2yvFDY','2026-05-24 05:47:56.432285','2026-06-23 05:47:56',8,'f4d44f13579245198306c1983293cb36');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (556,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE5Mzc1MSwiaWF0IjoxNzc5NjAxNzUxLCJqdGkiOiJiMjZjYzcyNmU3MjY0MmRjYjYxNDIxNWRmMmJmZjEyMSIsInVzZXJfaWQiOiI2In0.ffjt03vrZrwmSON9yZJZ6LsYA1yxmWMwtku5JqYkfoo','2026-05-24 05:49:11.671813','2026-06-23 05:49:11',6,'b26cc726e72642dcb614215df2bff121');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (557,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjE5NDY2MywiaWF0IjoxNzc5NjAyNjYzLCJqdGkiOiI5ZDExYWMwZWIxNGI0YTJkYWEzZGY5M2Q1MTdhN2MzZCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.t6QUb79CORJsDIkJNG58aXUzB4Ko9frGHurOXABJZyQ','2026-05-24 06:04:23.213990','2026-06-23 06:04:23',6,'9d11ac0eb14b4a2daa3df93d517a7c3d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (558,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4MjIxMSwiaWF0IjoxNzc5NjkwMjExLCJqdGkiOiIwNzNmNTc4ZWZkNmE0MzI5YTc2NjIyYmU1OGNiOWE5MiIsInVzZXJfaWQiOiIxNyJ9.MraldqdbLxCNSFFc-wp-dGvRytRcdZ9YzjiGEtw1K_Y','2026-05-25 06:23:31.954754','2026-06-24 06:23:31',17,'073f578efd6a4329a76622be58cb9a92');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (559,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4MzExOCwiaWF0IjoxNzc5NjkxMTE4LCJqdGkiOiJjMDg2ZGUzZDhjODI0YzMxYWQ2OTg2OWRmMjhlNTA1NCIsInVzZXJfaWQiOiI3In0.tUuTcr7_ggkdWAaUJbabvIyxV2NmZ7dgwl2LwUx8dqQ','2026-05-25 06:38:38.724277','2026-06-24 06:38:38',7,'c086de3d8c824c31ad69869df28e5054');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (560,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4MzIyNiwiaWF0IjoxNzc5NjkxMjI2LCJqdGkiOiI5YTFlNmI1YmQyZmY0MjBkOGZjMWU5ZGYxNmU2MGY5MSIsInVzZXJfaWQiOiI2In0.7jLmrUub0Weni0BeQai-ROwHBTkKUXfOfgyViqH4k2E','2026-05-25 06:40:26.105369','2026-06-24 06:40:26',6,'9a1e6b5bd2ff420d8fc1e9df16e60f91');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (561,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDI4MiwiaWF0IjoxNzc5NjkyMjgyLCJqdGkiOiJiMGVhYWU3NDVkZGU0OGUyYmEwMDUyNzc2ZjJjYWE3YSIsInVzZXJfaWQiOiI2In0.i9XvepskohNQu9r7apn3DmoP2fF0Btt93U38iloCcuI','2026-05-25 06:58:02.285163','2026-06-24 06:58:02',6,'b0eaae745dde48e2ba0052776f2caa7a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (562,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDYwNywiaWF0IjoxNzc5NjkyNjA3LCJqdGkiOiI0ZjQwMDMwZDVkNzU0ZjFkODFkZDgyZWQyZjA5NTkyYiIsInVzZXJfaWQiOiI2In0.NLOW6Sq78uh5MwLwSQCC_FoQTqH8F5DAmYqJx3GCuq8','2026-05-25 07:03:27.928883','2026-06-24 07:03:27',6,'4f40030d5d754f1d81dd82ed2f09592b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (563,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDYwOSwiaWF0IjoxNzc5NjkyNjA5LCJqdGkiOiJkNTAwOWZhOTgzMzI0ZTczODg2NzE1ZmQyYjA0OGVhMiIsInVzZXJfaWQiOiI4In0.lLK1HI9K7FQhPVh0Y-HDrdV80Pf0n7qWMIwxtSR3gGA','2026-05-25 07:03:29.004118','2026-06-24 07:03:29',8,'d5009fa983324e73886715fd2b048ea2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (564,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDYxMCwiaWF0IjoxNzc5NjkyNjEwLCJqdGkiOiIyNjExMjY3M2MyMDQ0NjU1OTNhNDNjOWFmZjVmNWNiNyIsInVzZXJfaWQiOiI3In0.Tv6kR7q2Koc3Fi0UQjclL50RTSZc48eTLw0E7voQqHI','2026-05-25 07:03:30.339048','2026-06-24 07:03:30',7,'26112673c204465593a43c9aff5f5cb7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (565,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDY3MCwiaWF0IjoxNzc5NjkyNjcwLCJqdGkiOiJiNDEyNzMxNjMzMTI0NWQxOGYwZjI2ZjliMjA0MGQ3YiIsInVzZXJfaWQiOiI3In0.1k2ah9RnOettWIAGBPLluQFslUrAKU85o3-OZSAGIB4','2026-05-25 07:04:30.121169','2026-06-24 07:04:30',7,'b4127316331245d18f0f26f9b2040d7b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (566,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDY3MSwiaWF0IjoxNzc5NjkyNjcxLCJqdGkiOiI5OTdmZjJjOTM5YWI0ZWFiODNhYWY4YWNkYTkxY2MyMSIsInVzZXJfaWQiOiI4In0.QQ74FzzD_16nSqDStmXj4RdeGBF_ga7MAWWtbYooRdg','2026-05-25 07:04:31.609348','2026-06-24 07:04:31',8,'997ff2c939ab4eab83aaf8acda91cc21');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (567,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDY3MywiaWF0IjoxNzc5NjkyNjczLCJqdGkiOiI5NzMwMDU4NjY0ODE0ODc0YmY0ODE0NDBhYTc3YjNhNSIsInVzZXJfaWQiOiI2In0.8WtF4fQOGLkGLv2yz7VlMMbCPr6wbCgjpeYzsQAnfIQ','2026-05-25 07:04:33.419355','2026-06-24 07:04:33',6,'9730058664814874bf481440aa77b3a5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (568,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDcyNCwiaWF0IjoxNzc5NjkyNzI0LCJqdGkiOiIwZGE2YTUxNjIxZDM0ZjVmODAwMjcyZGQ0MmE5YThhZCIsInVzZXJfaWQiOiI2In0.weYCcY6iTQt7IT8OcvyDF5uXrrspZ-rkbWCBo2s_pas','2026-05-25 07:05:24.764853','2026-06-24 07:05:24',6,'0da6a51621d34f5f800272dd42a9a8ad');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (569,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDgzMSwiaWF0IjoxNzc5NjkyODMxLCJqdGkiOiI2OWQyZjBlYjNjNDU0MzdkYWZmNmE1ZTVkY2FiYWU0ZCIsInVzZXJfaWQiOiI2In0.Nz9NbeMZGoUqcXaG5VWvHQXIrcxg-lUBEN0XQRS_q74','2026-05-25 07:07:11.000235','2026-06-24 07:07:11',6,'69d2f0eb3c45437daff6a5e5dcabae4d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (570,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NDgzNSwiaWF0IjoxNzc5NjkyODM1LCJqdGkiOiIyNjU3NWFjOWUwMjE0OWFjODQxNzdhMDc0YzUyYjJjMyIsInVzZXJfaWQiOiI3In0.vvfDGnYp5-KYXWCwXFhZVImIoZ5qgndbUhlpEOVo5k8','2026-05-25 07:07:15.182155','2026-06-24 07:07:15',7,'26575ac9e02149ac84177a074c52b2c3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (571,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4NjU3OSwiaWF0IjoxNzc5Njk0NTc5LCJqdGkiOiJhYjk3OTFjNjczMTM0MGZmOTg1NzBhMjk2Y2VjZjRhOCIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.p8KjGfwLJNbQqTW2ssGnD9aE4l71Z9we43wg4PvoR3M','2026-05-25 07:36:19.929338','2026-06-24 07:36:19',6,'ab9791c6731340ff98570a296cecf4a8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (572,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI4OTE1OSwiaWF0IjoxNzc5Njk3MTU5LCJqdGkiOiI5ZDE4OTA5NGViNzA0ZWY4YTE0ODgyMGRiYTlhZjkxNCIsInVzZXJfaWQiOiI2In0.ccggv9ZTKAVXDz_JuU5wT5Y6GMBxUe1hrBcXGBXx7Js','2026-05-25 08:19:19.519279','2026-06-24 08:19:19',6,'9d189094eb704ef8a148820dba9af914');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (573,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjI5MjgyOSwiaWF0IjoxNzc5NzAwODI5LCJqdGkiOiIxNDFmMDQwNTc5Mjk0NGJhYjYyYTEzOWIwMjJhYmM0ZiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.CK-K5U-0l-1DbkXRgv1iXaEGVacvuEhd8ReY5MxHWdc','2026-05-25 09:20:29.780193','2026-06-24 09:20:29',6,'141f0405792944bab62a139b022abc4f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (574,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxNjYyOCwiaWF0IjoxNzc5NzI0NjI4LCJqdGkiOiI4MTdiYTEyYjJhMzA0OTNkYjEzNzAzYTBkMjQyNjNkYyIsInVzZXJfaWQiOiIyMSJ9.gDnxYlFWfLGxfPkHWtjRzdDmzYYoS3JmB_Lj4B_QOhs','2026-05-25 15:57:08.555388','2026-06-24 15:57:08',21,'817ba12b2a30493db13703a0d24263dc');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (575,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxNjgwMywiaWF0IjoxNzc5NzI0ODAzLCJqdGkiOiI1YThjNjllZTU1MGE0MjVlYmE5NzU2NTNjOTc2YTJkMyIsInVzZXJfaWQiOiIyMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJzYW1lZXIyMDA0d2F0Z3VsZUBnbWFpbC5jb20ifQ.KSWSV36Vyk6WN_KjCQ5P9aB0VR2sJ-jCBt9jTE6UhzI','2026-05-25 16:00:03.141293','2026-06-24 16:00:03',21,'5a8c69ee550a425eba975653c976a2d3');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (576,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxNjg2MiwiaWF0IjoxNzc5NzI0ODYyLCJqdGkiOiIxN2MwY2VhNjZmMmM0MmE0YWNlYTA5N2JhOWQ0Zjc1NSIsInVzZXJfaWQiOiIyMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJzYW1lZXIyMDA0d2F0Z3VsZUBnbWFpbC5jb20ifQ.bS5x95s28v_UH4YgSvEwNh3Zp8PVywZLA5JeSrPX5ZU','2026-05-25 16:01:02.254410','2026-06-24 16:01:02',21,'17c0cea66f2c42a4acea097ba9d4f755');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (577,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxNzIyNCwiaWF0IjoxNzc5NzI1MjI0LCJqdGkiOiIxNjQ1ZTQ2MjNlNzI0NTc4YjI0YzgxZDdjMjAzNTIyNiIsInVzZXJfaWQiOiIyMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJzYW1lZXIyMDA0d2F0Z3VsZUBnbWFpbC5jb20ifQ.Bu1ZCTfMw90EcmF241VfVJ9nFSoEtW4l2aizvVFFniM','2026-05-25 16:07:04.256146','2026-06-24 16:07:04',21,'1645e4623e724578b24c81d7c2035226');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (578,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxNzIzNSwiaWF0IjoxNzc5NzI1MjM1LCJqdGkiOiIwZDhhMTEyMTc3MGE0ZDJkOGQzNGU0OWRhMDUzYjhiMSIsInVzZXJfaWQiOiIyMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJzYW1lZXIyMDA0d2F0Z3VsZUBnbWFpbC5jb20ifQ.yJ1FBltQ2m-IpPW6sgjVBqk1xwezcA_4OCcwDEe8UuE','2026-05-25 16:07:15.970241','2026-06-24 16:07:15',21,'0d8a1121770a4d2d8d34e49da053b8b1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (579,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxODIyOCwiaWF0IjoxNzc5NzI2MjI4LCJqdGkiOiJiMGVmZDg0YTRhZWY0MDQyOWFjYjFkNDMyZjIzZDNiNSIsInVzZXJfaWQiOiIyMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJzYW1lZXIyMDA0d2F0Z3VsZUBnbWFpbC5jb20ifQ.QmMfgFDojDK316sqMy62u-ribXAwh9UN-pdyiW6gfGQ','2026-05-25 16:23:48.824292','2026-06-24 16:23:48',21,'b0efd84a4aef40429acb1d432f23d3b5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (580,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxODMzNCwiaWF0IjoxNzc5NzI2MzM0LCJqdGkiOiIwZmMxOWM3NmNhZGM0MGM5YWE4ZDhhMzMzNjZkNmYxZCIsInVzZXJfaWQiOiI2In0.GPhWW3BwM7KbjyI7f10HNlS9e3TP996twRSvYf0l_Y4','2026-05-25 16:25:34.168613','2026-06-24 16:25:34',6,'0fc19c76cadc40c9aa8d8a33366d6f1d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (581,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxODg3NywiaWF0IjoxNzc5NzI2ODc3LCJqdGkiOiIzYTk4N2M2MjM0NmY0ZmFhOTNlZjdjODRkZjhhMDk1NCIsInVzZXJfaWQiOiI2In0.PCTsdX3YP6l700apSC7n1Pp3bmpDd0y6kpr9O48knFA','2026-05-25 16:34:37.389208','2026-06-24 16:34:37',6,'3a987c62346f4faa93ef7c84df8a0954');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (582,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMxODk4NCwiaWF0IjoxNzc5NzI2OTg0LCJqdGkiOiJjMzExYjQ4MGE1YmE0YjQ3YTMyMDI3NGVkMzVmYTdlNiIsInVzZXJfaWQiOiIyMSJ9.daU3k3S_puI1a0GhFi2yp0pPjUP-Nsa2tMsdLEhVaXY','2026-05-25 16:36:24.554668','2026-06-24 16:36:24',21,'c311b480a5ba4b47a320274ed35fa7e6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (583,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMyMDMzNCwiaWF0IjoxNzc5NzI4MzM0LCJqdGkiOiI5OWEwMTE4MWY1Mjg0OTliOTJhZWJhMWZlMjRmMDc2NyIsInVzZXJfaWQiOiIyMSIsInJvbGUiOiJ1c2VyIiwiZW1haWwiOiJzYW1lZXIyMDA0d2F0Z3VsZUBnbWFpbC5jb20ifQ.t2NdLF59-N0uxUocd5W83LtJX1jan-cJw9NVQZJgLdo','2026-05-25 16:58:54.599918','2026-06-24 16:58:54',21,'99a01181f528499b92aeba1fe24f0767');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (584,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjMyMjA4MCwiaWF0IjoxNzc5NzMwMDgwLCJqdGkiOiJjZTg4MjRhZjkyMDc0NmNjOWE0MWJjZjI2NWYxZjgyOSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.3qt8DfvYp4Om8pwgvkgBY3smt4G1KdaTdDwds5Li6pE','2026-05-25 17:28:00.642682','2026-06-24 17:28:00',6,'ce8824af920746cc9a41bcf265f1f829');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (585,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5MDU3NCwiaWF0IjoxNzc5Nzk4NTc0LCJqdGkiOiJmYTAyZTE5YzRmOTg0NDFlYmEwYjg3ZGM5OGMzZjQ5OCIsInVzZXJfaWQiOiI2In0.fsZ59kpLYpkkLvRN2cqY5maqACJexBnB5As-MMxqHKs','2026-05-26 12:29:34.823412','2026-06-25 12:29:34',6,'fa02e19c4f98441eba0b87dc98c3f498');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (586,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5OTEyMSwiaWF0IjoxNzc5ODA3MTIxLCJqdGkiOiJlNDFhNzUyNzI2Nzc0M2YyYjcyMTNkNjczOTNmOWFkZCIsInVzZXJfaWQiOiI3In0.Y9PuHhjjmYqRC7NGV9KrhE_A3K55fBj_eKlMXKqa_yc','2026-05-26 14:52:01.507412','2026-06-25 14:52:01',7,'e41a7527267743f2b7213d67393f9add');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (587,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5OTgxOSwiaWF0IjoxNzc5ODA3ODE5LCJqdGkiOiJlMmJlODYzZWYyZmY0M2NkYTA3NWQyNDc2ZTViYzkxOCIsInVzZXJfaWQiOiI2In0.vOYr7eIuzfPyM_c-pgUPqcZXzLjbYXAKTWYtJCSBPPc','2026-05-26 15:03:39.250040','2026-06-25 15:03:39',6,'e2be863ef2ff43cda075d2476e5bc918');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (588,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5OTgxOSwiaWF0IjoxNzc5ODA3ODE5LCJqdGkiOiJiNWJhNjEyZTk0MDI0MzUxOTE1YWU4NjNjM2ZhZWZiZCIsInVzZXJfaWQiOiI2In0.x3MzQpBdqDXiWIjgmEN4PHrROvRdMGv6AVnwpdRpAUI','2026-05-26 15:03:39.394570','2026-06-25 15:03:39',6,'b5ba612e94024351915ae863c3faefbd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (589,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5OTgxOSwiaWF0IjoxNzc5ODA3ODE5LCJqdGkiOiIxZjhmYThhZTYwNTk0OWU2YjdhNGI5MWQwOGQ1OWRiNyIsInVzZXJfaWQiOiI2In0.-aiGwYyjfpOiuCX7OQXlQhf9TaePIetKzo_qwZJsP80','2026-05-26 15:03:39.833543','2026-06-25 15:03:39',6,'1f8fa8ae605949e6b7a4b91d08d59db7');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (590,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5OTgxOSwiaWF0IjoxNzc5ODA3ODE5LCJqdGkiOiI3YjA0ODlhNjBiYjA0ZmMwYWIwODBkZDlkM2ZlMDhlYiIsInVzZXJfaWQiOiI2In0.2f4zRkAe5FYeMDTTCg_CT35iI-UkKRBNQ8oYKmUfcbk','2026-05-26 15:03:39.985246','2026-06-25 15:03:39',6,'7b0489a60bb04fc0ab080dd9d3fe08eb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (591,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjM5OTkyOSwiaWF0IjoxNzc5ODA3OTI5LCJqdGkiOiJlY2JlMjExOWY2NzE0M2FlODYwNjdiNjU0MjZjOTJhOCIsInVzZXJfaWQiOiI2In0.fpyMCkwf0NkkAhbelNVUmUXSSNMpcSo58yot1X2kP40','2026-05-26 15:05:29.343731','2026-06-25 15:05:29',6,'ecbe2119f67143ae86067b65426c92a8');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (592,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQwMDA0NSwiaWF0IjoxNzc5ODA4MDQ1LCJqdGkiOiI3ZTJkMjFhYzYwMDI0MGRkYWM1ZDM2YzJkNDhlYjcxNiIsInVzZXJfaWQiOiI3In0.MgRTBupJ9mRvaVZ2g4WoodFgJcqRrvshgHTZxJN9O0M','2026-05-26 15:07:25.330750','2026-06-25 15:07:25',7,'7e2d21ac600240ddac5d36c2d48eb716');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (593,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQwNzA3MywiaWF0IjoxNzc5ODE1MDczLCJqdGkiOiJjNTYwMmNmMWJiZWY0MGY1YjYzMGE2M2U4ODc4MmMxOCIsInVzZXJfaWQiOiI2In0.IotB23waTK8ybXmUVLVhupWSarFpa7kp_oRj85pzn-g','2026-05-26 17:04:33.090713','2026-06-25 17:04:33',6,'c5602cf1bbef40f5b630a63e88782c18');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (594,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQwNzA3NiwiaWF0IjoxNzc5ODE1MDc2LCJqdGkiOiI5NWI2NGUwY2E4Mjc0MTcyODhlMzE1ZTY2N2I5NzhjZiIsInVzZXJfaWQiOiI3In0.4QeHWTXCtt9CKsFaWFUfo-z7cwi1oWu0z_PLhlc8ILc','2026-05-26 17:04:36.428578','2026-06-25 17:04:36',7,'95b64e0ca827417288e315e667b978cf');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (595,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQwNzA4MCwiaWF0IjoxNzc5ODE1MDgwLCJqdGkiOiIyOGQ2MzkwZWJjYTc0YWE1YWVmYTRlMDUzM2ZmOGNjZCIsInVzZXJfaWQiOiI4In0.a2WBOxe6eTElk5M8NWhMIit3J4Ctg4UYhi8yYB_W5fc','2026-05-26 17:04:40.444156','2026-06-25 17:04:40',8,'28d6390ebca74aa5aefa4e0533ff8ccd');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (596,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQwNzIyNSwiaWF0IjoxNzc5ODE1MjI1LCJqdGkiOiI5OWMxYzc5NDdjZWQ0NTdmYjFhZjUwZGY2Yjc4YzBmNCIsInVzZXJfaWQiOiI3In0.cvPqDrOEhswEO01sJmmVte_3IDd_gA4qxeOReKsqqr0','2026-05-26 17:07:05.094310','2026-06-25 17:07:05',7,'99c1c7947ced457fb1af50df6b78c0f4');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (597,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQzNjUwOSwiaWF0IjoxNzc5ODQ0NTA5LCJqdGkiOiIxYTBjMjliYTUzY2I0MTU0YjhlOTNjMmEzODVmODYyYSIsInVzZXJfaWQiOiI2In0.75IC84XkcdMeKV7yuNMmxabmCyb19Xri-e_WvTZzZF0','2026-05-27 01:15:09.535129','2026-06-26 01:15:09',6,'1a0c29ba53cb4154b8e93c2a385f862a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (598,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ0OTM1OCwiaWF0IjoxNzc5ODQ0NTU4LCJqdGkiOiJjOTg1YjlkYzA5ZWM0MTA4OTg4YTM2MmQxM2NlOTk4ZiIsInVzZXJfaWQiOiIyMiJ9.bDzsh7-riilp8WoxCvMwou8bjHNRtiQs7XIDHZ2XVRs','2026-05-27 01:15:58.095406','2026-06-03 01:15:58',22,'c985b9dc09ec4108988a362d13ce998f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (599,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ1NDkyOSwiaWF0IjoxNzc5ODUwMTI5LCJqdGkiOiI0NTg3NjMxNDFmN2U0NzBkOTFmMjI0YWJhMzRmNzE2ZSIsInVzZXJfaWQiOiIyMiJ9.zJFDVK3IQwZTiEsUB_X0tLlUJUhOdjBUL9TQj6GqKSI','2026-05-27 02:48:49.529371','2026-06-03 02:48:49',22,'458763141f7e470d91f224aba34f716e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (600,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ1NDkyOSwiaWF0IjoxNzc5ODUwMTI5LCJqdGkiOiJjYmY4NmZlZWI4MTA0MTM3YjhkMGI1ZWNmNmZlOTgyNyIsInVzZXJfaWQiOiIyMiJ9.qYEhAMoUbsAehIY4Gg7OF0q2J-jZoRZuWbdF8g_I_nc','2026-05-27 02:48:49.535495','2026-06-03 02:48:49',22,'cbf86feeb8104137b8d0b5ecf6fe9827');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (601,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjQ0MjMwOSwiaWF0IjoxNzc5ODUwMzA5LCJqdGkiOiJjODVkYWFjMTU4ZTI0NzE3OWQzMzg4YmMxNWUzNTdjNiIsInVzZXJfaWQiOiI2In0.YJ9SF3l-hRDJj4SX37wOVz_Ftv5pN7TQQbBTuVQUNGU','2026-05-27 02:51:49.639818','2026-06-26 02:51:49',6,'c85daac158e247179d3388bc15e357c6');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (602,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ2ODk2MiwiaWF0IjoxNzc5ODY0MTYyLCJqdGkiOiI4NTE2MTYwMTNjYTg0ZWM4OWI2MTY3ZGYwYmZiYjkyYSIsInVzZXJfaWQiOiIyMiJ9.MtPloMOD3whvVGOlkVv5uW_ZBVLPgKFSVKR8qN8CDvg','2026-05-27 06:42:42.750232','2026-06-03 06:42:42',22,'851616013ca84ec89b6167df0bfbb92a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (603,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ2ODk2MiwiaWF0IjoxNzc5ODY0MTYyLCJqdGkiOiI5Nzk1NTdjNTgwZWI0MGIzOWU2NDdlZWJkOWYzZDY1ZiIsInVzZXJfaWQiOiIyMiJ9.61_3oq_hXWsH7QaX7E-H-8l4rg-cVORRhCyHktpKzOE','2026-05-27 06:42:42.769334','2026-06-03 06:42:42',22,'979557c580eb40b39e647eebd9f3d65f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (604,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ3MTQxMSwiaWF0IjoxNzc5ODY2NjExLCJqdGkiOiJmNmM5OTUxMmNmNjg0MjMyODVmMjc3NDBjOTFmYWM4MyIsInVzZXJfaWQiOiIyMiJ9.V9ZfgAXw0nVpBdYy4q7mP7_ni95ai5zDMtzDFAEatBw','2026-05-27 07:23:31.305997','2026-06-03 07:23:31',22,'f6c99512cf68423285f27740c91fac83');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (605,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ3MTgzOCwiaWF0IjoxNzc5ODY3MDM4LCJqdGkiOiJlMWEwMTIxNjJlNzQ0MjQ3ODkzZTMyMzliNDNmYTk5YiIsInVzZXJfaWQiOiIyMiJ9.k1wkQneGImjRVQEAGF0libqPBLl7cl9xqn_KDyx7c_k','2026-05-27 07:30:38.532804','2026-06-03 07:30:38',22,'e1a012162e744247893e3239b43fa99b');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (606,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ5MTk5MCwiaWF0IjoxNzc5ODg3MTkwLCJqdGkiOiIxZTM0MjE0MTQ4NGY0NDRiYWQyMmYyNTk3NThiNjMxZSIsInVzZXJfaWQiOiIyMiJ9.yVMKbuKESJfsNU6u7Fl0ZBHMDf7fxD8xErGOAzSaIz4','2026-05-27 13:06:30.738633','2026-06-03 13:06:30',22,'1e342141484f444bad22f259758b631e');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (607,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ5MTk5MCwiaWF0IjoxNzc5ODg3MTkwLCJqdGkiOiI3MGUyYjg3M2ZiZjQ0NzRhOGI5YjhlMmU4NDI3MTc2OSIsInVzZXJfaWQiOiIyMiJ9.NM5EfWfu0b4TqKA456EYzNo6v2tbk-w_TJMTADtjdj0','2026-05-27 13:06:30.740154','2026-06-03 13:06:30',22,'70e2b873fbf4474a8b9b8e2e84271769');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (608,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDQ5NTc2MCwiaWF0IjoxNzc5ODkwOTYwLCJqdGkiOiIyOTNiYjU3MDMxMTI0MGI3YmZkZDEyZThiM2M4OTQ0MSIsInVzZXJfaWQiOiIyMyJ9.TeXHvM2eDUgb9XOjXWugws1jBI7X3rL6ICFyspXwy2U','2026-05-27 14:09:20.284652','2026-06-03 14:09:20',NULL,'293bb570311240b7bfdd12e8b3c89441');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (609,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU4OTA1NiwiaWF0IjoxNzc5OTg0MjU2LCJqdGkiOiI2MmM0Y2ZkYjE2ODY0Yzk2OWQyNjk3Y2UwODRmNWM5ZiIsInVzZXJfaWQiOiIyMiJ9._qPQ541qoGRHKCx9hXiM2rekbOwOs3FgnOrvMdh2Fs8','2026-05-28 16:04:16.127558','2026-06-04 16:04:16',22,'62c4cfdb16864c969d2697ce084f5c9f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (610,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MjUyNCwiaWF0IjoxNzc5OTg3NzI0LCJqdGkiOiIyNjRmNGZjYmVlYTQ0YmM0OGUyZDUzNGIxMThlYmEzMSIsInVzZXJfaWQiOiIyNCJ9.ryBS0DA0EulNUBGLLiutyx5hYwmpwRJOiC_4UzREuB8','2026-05-28 17:02:04.734978','2026-06-04 17:02:04',NULL,'264f4fcbeea44bc48e2d534b118eba31');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (611,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MjYzNywiaWF0IjoxNzc5OTg3ODM3LCJqdGkiOiIwZDU5MGQ3N2FjYWU0YTEwYjJiNTM0YzQ3M2E1MDQ0OCIsInVzZXJfaWQiOiIyNCJ9.gCxmXX4MKgGZvhu28qPRUXIGDXBjuT5rEpsXhGKTVj0','2026-05-28 17:03:57.379407','2026-06-04 17:03:57',NULL,'0d590d77acae4a10b2b534c473a50448');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (612,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MjY5MCwiaWF0IjoxNzc5OTg3ODkwLCJqdGkiOiIwNjk5NTdlM2ZjMTE0MjUxOTE0ZDM3MGQyYjE5ZDg2ZCIsInVzZXJfaWQiOiIyNCJ9.Yuby74dCHce8EQ0N2VjPhzr2SygogOgm4FyFJxwMqs0','2026-05-28 17:04:50.914056','2026-06-04 17:04:50',NULL,'069957e3fc114251914d370d2b19d86d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (613,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MjkwMywiaWF0IjoxNzc5OTg4MTAzLCJqdGkiOiIwNzAyYjQ2ODVhNDU0YWQ5YjM1ZjJkNmEzNzVlMGNiOSIsInVzZXJfaWQiOiIyMiJ9.dH5MatCJs1VFpwF5ifaLuqtwnN68fLDnQK5PrK6-PjY','2026-05-28 17:08:23.844939','2026-06-04 17:08:23',22,'0702b4685a454ad9b35f2d6a375e0cb9');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (614,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MjkwMywiaWF0IjoxNzc5OTg4MTAzLCJqdGkiOiIwNTFjODVkN2NhN2M0ZjJiYmM1MzhmODc2MjI3ZGVmYSIsInVzZXJfaWQiOiIyMiJ9.Uy2YrGgIu0kOEYYfzvDUbj6Xbdm1OQ938y69LqVRb80','2026-05-28 17:08:23.841397','2026-06-04 17:08:23',22,'051c85d7ca7c4f2bbc538f876227defa');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (615,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MzU4MCwiaWF0IjoxNzc5OTg4NzgwLCJqdGkiOiIzMTZkOTZmZGJkOWI0YTBjYjc3NDMxOTE0Y2Y1ZDg5ZCIsInVzZXJfaWQiOiIyNSJ9.cFLf48fZyk_GndE3pEGVef0cKCrntyD_Hzf1ZnKwSr0','2026-05-28 17:19:40.116030','2026-06-04 17:19:40',NULL,'316d96fdbd9b4a0cb77431914cf5d89d');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (616,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MzYwMSwiaWF0IjoxNzc5OTg4ODAxLCJqdGkiOiI3YmU0ZjA3MGE5NjQ0OTYyOTU2OWQwMjAwMWNlMTM5MSIsInVzZXJfaWQiOiIyNSJ9.Sm51do4QVhg53X9oJYFfX-k_Hx8ez-J7gX5fsxfGBKU','2026-05-28 17:20:01.165239','2026-06-04 17:20:01',NULL,'7be4f070a96449629569d02001ce1391');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (617,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MzYyMSwiaWF0IjoxNzc5OTg4ODIxLCJqdGkiOiJkZjVkZTFlNGZhZWY0YzM2YjkyZjQyYzdmOThmMzZmYiIsInVzZXJfaWQiOiIyNSJ9.0QpdWnpOpN9gPMD_OQR67j2RuwiyVZgvF2VFkVsP-3s','2026-05-28 17:20:21.363386','2026-06-04 17:20:21',NULL,'df5de1e4faef4c36b92f42c7f98f36fb');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (618,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MzY1MiwiaWF0IjoxNzc5OTg4ODUyLCJqdGkiOiI2ZWE2MjAzN2QyNjI0NDY4OWU1ODZhMTFjMTQwZWQyMSIsInVzZXJfaWQiOiIyNSJ9.3R2JaxTveltYlRmycisKJolEYIi5PYidyk8jtu27uB0','2026-05-28 17:20:52.098371','2026-06-04 17:20:52',NULL,'6ea62037d26244689e586a11c140ed21');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (619,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MzY3MiwiaWF0IjoxNzc5OTg4ODcyLCJqdGkiOiI5MTQyN2MzNTc3MjA0NDllYjUxMzZmOTEwMWI0ZDE2OCIsInVzZXJfaWQiOiIyNSJ9.dnCx35yQdbUFBmVmdTYoVTBVlk_RccByk1sWaJIj36s','2026-05-28 17:21:12.994823','2026-06-04 17:21:12',NULL,'91427c357720449eb5136f9101b4d168');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (620,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5MzcwMiwiaWF0IjoxNzc5OTg4OTAyLCJqdGkiOiJiNzE0NzIxYTEzZjU0NjM1Yjc1NGI1OTUyZDAyNjVhMSIsInVzZXJfaWQiOiIyNSJ9.vcqBO9Gx-vUQRW70cMoZYSzzDUaqfxPr-tfbAqhfohU','2026-05-28 17:21:42.477881','2026-06-04 17:21:42',NULL,'b714721a13f54635b754b5952d0265a1');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (621,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5NTQ2MywiaWF0IjoxNzc5OTkwNjYzLCJqdGkiOiIxNmVhNTk0ZWYzNDE0ZjBiOTUyNWU2ZTVkYjg3NjI3NCIsInVzZXJfaWQiOiIyMiJ9._svMTvSUuji6P91HC9BmS8LJGC5OZwKan4G8PxAnObg','2026-05-28 17:51:03.067059','2026-06-04 17:51:03',22,'16ea594ef3414f0b9525e6e5db876274');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (622,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5NTQ2MywiaWF0IjoxNzc5OTkwNjYzLCJqdGkiOiJlMDdkNWU3M2I5MDg0NGI0OGNlOTU3OWExMzdjZDgxMCIsInVzZXJfaWQiOiIyMiJ9.TqaLxL1wHgH2fvfObi0YhC1a25o3qi66fSd2fwmyhuM','2026-05-28 17:51:03.065546','2026-06-04 17:51:03',22,'e07d5e73b90844b48ce9579a137cd810');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (623,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDU5OTQ4NiwiaWF0IjoxNzc5OTk0Njg2LCJqdGkiOiI2ZjkyNWVmMWRiMjk0ZjE5OThlMjc4Y2IwZmVhYWQwMSIsInVzZXJfaWQiOiIyMiJ9.NkMyJmEB2U-NyX47ZFlz6RhSeJbxgKeDf-tmuydLgE0','2026-05-28 18:58:06.864320','2026-06-04 18:58:06',22,'6f925ef1db294f1998e278cb0feaad01');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (624,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyNjEwNSwiaWF0IjoxNzgwMDM0MTA1LCJqdGkiOiI1ZDQxMTcyZjNlZjE0ZWRjOTBkNzcxOWFjMmM5NGEyYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.118Ahj77u3RfnAC7O8p0hElDsF0vizwT4WepUHs8DEA','2026-05-29 05:55:05.629863','2026-06-28 05:55:05',6,'5d41172f3ef14edc90d7719ac2c94a2a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (625,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyNjExMiwiaWF0IjoxNzgwMDM0MTEyLCJqdGkiOiI2ZWM4ZjM4OWMwOWM0NTExODJhMTNiZGUyYzg0NjRjZiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.zJqmCKy3mOuRKIqWiyqHO3xNF_B-B3ExuAd9CXFnGGY','2026-05-29 05:55:12.818498','2026-06-28 05:55:12',6,'6ec8f389c09c451182a13bde2c8464cf');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (626,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MDYzOTAzNCwiaWF0IjoxNzgwMDM0MjM0LCJqdGkiOiJmNGM4M2Q2MTc1MjE0MGZhYmNlY2Q4MTAwZTQxOWQ2MSIsInVzZXJfaWQiOiIyMiJ9.0D73QvMXC_OB63KBtMz69XuJvZPtbok_siaZeV440dk','2026-05-29 05:57:14.677809','2026-06-05 05:57:14',22,'f4c83d61752140fabcecd8100e419d61');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (627,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyNjgwOCwiaWF0IjoxNzgwMDM0ODA4LCJqdGkiOiI1OWE4YWQ1YWJkZGQ0NTVjODNmNzVmZWM5ODAyNGUwMiIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.vcl4TXIGLSNCgBEbVpHLc9s1g5NAII16Pr0eIGjKTHE','2026-05-29 06:06:48.937773','2026-06-28 06:06:48',6,'59a8ad5abddd455c83f75fec98024e02');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (628,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyNjgxMywiaWF0IjoxNzgwMDM0ODEzLCJqdGkiOiIzOGRmYTBlOGFkZjk0YjJlOGEwMTI5ZWRmZmVjOGJjYSIsInVzZXJfaWQiOiI2Iiwicm9sZSI6ImFkbWluIiwiZW1haWwiOiJkZXYtYWRtaW5AZnVybmlzaG9wLmxvY2FsIn0.Vf-k0lkzV9bdqFVvlW4sF9xrQlrsF25yzJh3VoDjad0','2026-05-29 06:06:53.935668','2026-06-28 06:06:53',6,'38dfa0e8adf94b2e8a0129edffec8bca');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (629,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyODYyNSwiaWF0IjoxNzgwMDM2NjI1LCJqdGkiOiI5NzMzYjc5MGI0N2M0Nzg3OTQ1ZmIxYzNlZWY0YTZkNSIsInVzZXJfaWQiOiI4In0.DvnIm_5ylQSlooiI6-h-tJha_d29VTf0puqxGs5aUTs','2026-05-29 06:37:05.521146','2026-06-28 06:37:05',8,'9733b790b47c4787945fb1c3eef4a6d5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (630,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyODg5MywiaWF0IjoxNzgwMDM2ODkzLCJqdGkiOiJjMzRjOGM5NTJiMjM0Mzg5ODc0YzY2YjMyMDc3Yjk5YSIsInVzZXJfaWQiOiI3In0.EPMzQdsooqX1VbpzdQbIY8ceiMIMSlfASs937z3EX4o','2026-05-29 06:41:33.963566','2026-06-28 06:41:33',7,'c34c8c952b234389874c66b32077b99a');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (631,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyODkzMiwiaWF0IjoxNzgwMDM2OTMyLCJqdGkiOiIxYzRmZGM3ZDMyMjY0YWE2YWRiMDAxYjgyMjFhOTA5ZiIsInVzZXJfaWQiOiI3Iiwicm9sZSI6InVzZXIiLCJlbWFpbCI6ImRldi11c2VyQGZ1cm5pc2hvcC5sb2NhbCJ9.P5o1LR2qh-pBs-hsiXagECr5MtKrg0AGcvgdi0Y55zA','2026-05-29 06:42:12.501383','2026-06-28 06:42:12',7,'1c4fdc7d32264aa6adb001b8221a909f');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (632,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjYyOTE0MywiaWF0IjoxNzgwMDM3MTQzLCJqdGkiOiI2MDE1MDMwMjExYWI0M2FmYjZhNTcxYzdjMzdkYjQxNSIsInVzZXJfaWQiOiI2In0.FqMtJeLf9DUtCTDhLl87LYzGNzA2qoX_4thGSDysKPM','2026-05-29 06:45:43.921029','2026-06-28 06:45:43',6,'6015030211ab43afb6a571c7c37db415');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (633,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjY0MTk5MSwiaWF0IjoxNzgwMDQ5OTkxLCJqdGkiOiI5MzRmYzZmYzg0ZjQ0OWY4OGNkNGE0ODdlM2UzZGZjMiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.4zNZE_tMYdnYZ0heC8szs4EOKzEd8HAKIjQzbgRKQjA','2026-05-29 10:19:51.330075','2026-06-28 10:19:51',8,'934fc6fc84f449f88cd4a487e3e3dfc2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (634,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjY0MTk5NSwiaWF0IjoxNzgwMDQ5OTk1LCJqdGkiOiI1MDBiM2NmYzAxYTU0YWIxOGRhNTM2NjU1MzQ0ZDNjZSIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.6IE-Dqre8L3-4IsS8xda2KBuLnH5wAfp0wRFStDBq58','2026-05-29 10:19:55.437323','2026-06-28 10:19:55',8,'500b3cfc01a54ab18da536655344d3ce');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (635,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjY0MTk5OSwiaWF0IjoxNzgwMDQ5OTk5LCJqdGkiOiI4MDYwMjYyMzBlNDA0OGU2YTI1ODA2YjE4Mjk1YTk1NiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.c_OcYE91Hc5wGr_k6pz48X_uOervmg8ZSnkt1YPx_VI','2026-05-29 10:19:59.084730','2026-06-28 10:19:59',8,'806026230e4048e6a25806b18295a956');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (636,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjY0MjAwMywiaWF0IjoxNzgwMDUwMDAzLCJqdGkiOiJjYjkxNjk4ZTY2NWQ0MTkzYWY1ZDcwMmZjNDEzMzBmMiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.V_y8YTJtDt42BXZ9G7X0SsAkd4H3Brf11hjQu5aq8-E','2026-05-29 10:20:03.202593','2026-06-28 10:20:03',8,'cb91698e665d4193af5d702fc41330f2');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (637,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjY0MjAyNywiaWF0IjoxNzgwMDUwMDI3LCJqdGkiOiI3ODMwMTI1Y2VkZWI0ZjkxOTA2ZDljNzlkZmMyZjZjNSIsInVzZXJfaWQiOiI4In0.brRYPgCMi32L_Dto2oAgOPSNpz8ciEuLMmXCc-slgp4','2026-05-29 10:20:27.478608','2026-06-28 10:20:27',8,'7830125cedeb4f91906d9c79dfc2f6c5');
INSERT INTO `token_blacklist_outstandingtoken` (`id`,`token`,`created_at`,`expires_at`,`user_id`,`jti`) VALUES (638,'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc4MjY0MjEwNiwiaWF0IjoxNzgwMDUwMTA2LCJqdGkiOiJjYTc1MTVmNmE2MDY0ZDc0YjIwZTMzYmQ1MzcyNTlmZiIsInVzZXJfaWQiOiI4Iiwicm9sZSI6ImRlYWxlciIsImVtYWlsIjoiZGV2LWRlYWxlckBmdXJuaXNob3AubG9jYWwiLCJkZWFsZXJfc3RhdHVzIjoiYWN0aXZlIn0.9VT4MADqOGfsszKHobsgwwLG2dTI8VTjjEEcaLTVqBM','2026-05-29 10:21:46.638820','2026-06-28 10:21:46',8,'ca7515f6a6064d74b20e33bd537259ff');

DROP TABLE IF EXISTS `user_addresses`;
CREATE TABLE `user_addresses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `full_name` varchar(120) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `line1` varchar(200) NOT NULL,
  `line2` varchar(200) NOT NULL,
  `landmark` varchar(120) NOT NULL,
  `city` varchar(120) NOT NULL,
  `state` varchar(120) NOT NULL,
  `postal_code` varchar(20) NOT NULL,
  `country` varchar(80) NOT NULL,
  `address_type` varchar(12) NOT NULL,
  `is_default_shipping` tinyint(1) NOT NULL,
  `is_default_billing` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `user_addres_user_id_f26943_idx` (`user_id`,`is_default_shipping`),
  KEY `user_addres_user_id_24a34c_idx` (`user_id`,`is_default_billing`),
  KEY `user_addresses_is_default_shipping_8926a2e2` (`is_default_shipping`),
  KEY `user_addresses_is_default_billing_dbd234d2` (`is_default_billing`),
  CONSTRAINT `user_addresses_user_id_c7113441_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `email` varchar(254) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `dealer_company_name` varchar(200) DEFAULT NULL,
  `dealer_gst_number` varchar(15) DEFAULT NULL,
  `dealer_status` varchar(10) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `role` varchar(10) NOT NULL,
  `is_blocked` tinyint(1) NOT NULL,
  `dealer_territory` varchar(80) DEFAULT NULL,
  `dealer_tier_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `users_email_0ea73cca_uniq` (`email`),
  KEY `users_dealer_tier_id_7dafba20_fk_dealer_tiers_id` (`dealer_tier_id`),
  CONSTRAINT `users_dealer_tier_id_7dafba20_fk_dealer_tiers_id` FOREIGN KEY (`dealer_tier_id`) REFERENCES `dealer_tiers` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (1,'pbkdf2_sha256$1000000$5ccOZ6b2rlBFX5W4hYjD2T$KovA3ixNURZ8imX39KLBbEz0vsrAJF89Cpc3lo6geb4=',NULL,1,'admin@furnishop.local','Site','Admin','admin@furnishop.local',1,1,'2026-05-10 15:58:14.264720',NULL,NULL,NULL,NULL,'admin',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (2,'pbkdf2_sha256$1000000$zBg0LGHYUqPaQuMVASSBt2$mAnnefIz4g7pzJroGb+KXzmBSj5n8VXMLxAzMY4REYY=',NULL,0,'shopper-1@example.com','Asha','Kumar','shopper-1@example.com',0,1,'2026-05-10 15:58:16.986532',NULL,NULL,NULL,NULL,'user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (3,'pbkdf2_sha256$1000000$V9GlpmPef2lmZ1KOMFH5bm$jvf3KhLLaGCVeAlaP4H+plG8cTScuXgG5Y909aWT25M=',NULL,0,'shopper-blocked@example.com','Blocked','Shopper','shopper-blocked@example.com',0,1,'2026-05-10 15:58:20.370559',NULL,NULL,NULL,NULL,'user',1,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (4,'pbkdf2_sha256$1000000$Rn0YsPopCKzYB25FaB39V4$khhsaWLbXneQcw32tMIrviHb9DrSWLfWruEMY51+MsY=',NULL,0,'dealer-active@example.com','Active','Dealer','dealer-active@example.com',0,1,'2026-05-10 15:58:23.186227','Active Dealer LLP','27ABCDE1234F1Z5','active',NULL,'dealer',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (5,'pbkdf2_sha256$1000000$XvfypnmOT66c27rNZV8dLs$KSXOOn6yp87gn915bOF5hH2RV4QbpH5khJExnN7TN4w=',NULL,0,'dealer-pending@example.com','Pending','Dealer','dealer-pending@example.com',0,1,'2026-05-10 15:58:25.996045','Pending Dealer Co.',NULL,'pending',NULL,'dealer',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (6,'pbkdf2_sha256$1000000$uHyzS3Q6btTZo9IfblgAXG$oGHEkqstjK5lFJaMFCCRJszwXI/A/hXwJnj1CWyIIl4=',NULL,1,'dev-admin@furnishop.local','Dev','Admin','dev-admin@furnishop.local',1,1,'2026-05-10 16:08:51.452123','','',NULL,NULL,'admin',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (7,'pbkdf2_sha256$1000000$7CVjZ5E8uhSYyxCrYaguFT$MZcEegPc17egazhcDLy+ACSqhFbKTYQmQUMc/WPxZac=',NULL,0,'dev-user@furnishop.local','Dev','User','dev-user@furnishop.local',0,1,'2026-05-10 16:12:01.308110','','',NULL,NULL,'user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (8,'pbkdf2_sha256$1000000$f1L11nKfv5CeJQIxIVzV8z$VRez3IWRIX9PuUtef8fsYXTyIFzRSpOXAjvSsTv4V0g=','2026-05-12 15:33:35.919607',0,'dev-dealer@furnishop.local','Dev','Dealer','dev-dealer@furnishop.local',0,1,'2026-05-10 16:17:10.175824','Dev Dealer Co.','29ABCDE1234F1Z5','active',NULL,'dealer',0,NULL,4);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (9,'pbkdf2_sha256$1000000$VSduU1mkHZp6wiituFGBX1$YbwlEq4xFl23dgxRGdWR1/v826xvomZaJAn35lC2ioI=',NULL,0,'testfunc@example.com','Test','User Functional','testfunc@example.com',0,1,'2026-05-11 08:23:07.034002',NULL,NULL,NULL,'9876543210','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (10,'pbkdf2_sha256$1000000$4IjM6oo6f85mUYDLhxP5ED$c2I5RWsC8ZGctGU9brD+ewXA1YQAhQJ7z4HaNdnnJwo=',NULL,0,'john@dealer.com','John','Dealer','john@dealer.com',0,1,'2026-05-12 07:59:16.088095','Dealer Corp','12ABCDE3456F7Z8','active','9876543210','dealer',0,NULL,3);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (11,'pbkdf2_sha256$1000000$DSp7IafuLNlZOZVyFTHm3b$crJ89ovbZVPGuwPq0fcq2N0n0UnCOQFn04xOEOra6Mw=',NULL,0,'testuser@example.com','Test','User','testuser@example.com',0,1,'2026-05-12 08:01:02.527849',NULL,NULL,NULL,'1112223333','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (12,'pbkdf2_sha256$1000000$m5dABS5E7KKfj8NSzvG3n5$SRD904XT0UygI2UufP5X1W6nBFKOEIYy8vATtQk7n8g=',NULL,0,'test-user@furnishop.local','Test','User','test-user@furnishop.local',0,1,'2026-05-13 07:13:22.255004',NULL,NULL,NULL,'9999999999','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (13,'pbkdf2_sha256$1000000$v6Hl9VSjaVnfqM9JDTEZpG$+GJ4BoKnYUZUlsUeqeg1KQQd4FG9jN/jBbA0knqrRPk=',NULL,0,'new-dealer@furnishop.local','New','Dealer','new-dealer@furnishop.local',0,1,'2026-05-13 07:16:11.521551','New Dealer Co.','27ABCDE1234F1Z5','pending','8888888888','dealer',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (14,'pbkdf2_sha256$1000000$9ptx9qWcj3buA0ytzjpGqh$0PRUrpv8TjUu910JsIq7KLtZKCmgScNECWmFXB6ZII4=',NULL,0,'rahul@gmail.com','Rahul','Chawla','rahul@gmail.com',0,1,'2026-05-18 08:12:15.758408',NULL,NULL,NULL,'9876543210','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (15,'pbkdf2_sha256$1000000$lSSBklOVUmJhJmXaOhsFON$4YYomCO4oV16mGmZtH4OGXRi+fJTFf+vWpkyQsfQpjg=',NULL,0,'rahulcha@gmail.com','Rahul','Chawla','rahulcha@gmail.com',0,1,'2026-05-18 08:21:51.165291','Furnotech','22AAAAA0000A1Z5','active','9876543210','dealer',0,NULL,4);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (17,'pbkdf2_sha256$1000000$EfhhMkohFO5FFFFZYPRZWL$0gsgX4FB2aHc/iOKPnco7KwhhC7Bst4gT6wrQuuJVe4=',NULL,0,'harshchakravarti77@gmail.com','Harsh','','harshchakravarti77@gmail.com',0,1,'2026-05-23 04:48:32.378623',NULL,NULL,NULL,'','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (19,'pbkdf2_sha256$1000000$0mVhAKygZibNvhydoRasTQ$N8v9RAfxeoyF1rnoCXEzARJHWtu9g3KizUtubAKR2Bk=',NULL,0,'falema3169@nuitx.com','Samir','Watgule','falema3169@nuitx.com',0,1,'2026-05-23 13:19:55.161579',NULL,NULL,NULL,'','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (20,'pbkdf2_sha256$1000000$MPBPW4eD1VhlkZx4iwQMlA$I1Tj1sINPcuwAsHJBUJPBUMfEwZEFoPYVFa1OeRSUTg=',NULL,0,'fun@furno.com','Fun2','','fun@furno.com',1,1,'2026-05-24 03:13:14.266677',NULL,NULL,NULL,'','admin',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (21,'pbkdf2_sha256$1000000$4GQdLmAcpaCtVYKnpynDd3$idVzmo9+tVpVdo3cbPhHvuFYptujxf48O3BttjDqJjE=',NULL,0,'sameer2004watgule@gmail.com','Samir','Ganesh Watgule','sameer2004watgule@gmail.com',0,1,'2026-05-25 15:56:23.251934',NULL,NULL,NULL,'8208967150','user',0,NULL,NULL);
INSERT INTO `users` (`id`,`password`,`last_login`,`is_superuser`,`username`,`first_name`,`last_name`,`email`,`is_staff`,`is_active`,`date_joined`,`dealer_company_name`,`dealer_gst_number`,`dealer_status`,`phone`,`role`,`is_blocked`,`dealer_territory`,`dealer_tier_id`) VALUES (22,'pbkdf2_sha256$720000$nVPeYtXtCVKmL2pQxvY35n$kqMY6ya78K2G7gHCbsCOJDAiScurnuB65p13u7FoqZk=','2026-05-19 17:00:39.535801',1,'admin','','','admin@furnotech.in',1,1,'2026-05-13 10:48:19.702698',NULL,NULL,NULL,NULL,'customer',0,NULL,NULL);

DROP TABLE IF EXISTS `users_groups`;
CREATE TABLE `users_groups` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `group_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_groups_user_id_group_id_fc7788e8_uniq` (`user_id`,`group_id`),
  KEY `users_groups_group_id_2f3517aa_fk_auth_group_id` (`group_id`),
  CONSTRAINT `users_groups_group_id_2f3517aa_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `users_groups_user_id_f500bee5_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `users_user_permissions`;
CREATE TABLE `users_user_permissions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) NOT NULL,
  `permission_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_user_permissions_user_id_permission_id_3b86cbdf_uniq` (`user_id`,`permission_id`),
  KEY `users_user_permissio_permission_id_6d08dcd2_fk_auth_perm` (`permission_id`),
  CONSTRAINT `users_user_permissio_permission_id_6d08dcd2_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `users_user_permissions_user_id_92473840_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

DROP TABLE IF EXISTS `wallet_transactions`;
CREATE TABLE `wallet_transactions` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `kind` varchar(8) NOT NULL,
  `amount` decimal(12,2) NOT NULL,
  `balance_after` decimal(12,2) NOT NULL,
  `reason` varchar(200) NOT NULL,
  `reference` varchar(100) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `actor_id` bigint(20) DEFAULT NULL,
  `order_id` bigint(20) DEFAULT NULL,
  `wallet_id` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `wallet_transactions_actor_id_26fa778f_fk_users_id` (`actor_id`),
  KEY `wallet_transactions_order_id_2ac15662_fk_orders_id` (`order_id`),
  KEY `wallet_transactions_wallet_id_8cb3251a_fk_dealer_wallets_id` (`wallet_id`),
  CONSTRAINT `wallet_transactions_actor_id_26fa778f_fk_users_id` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `wallet_transactions_order_id_2ac15662_fk_orders_id` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`),
  CONSTRAINT `wallet_transactions_wallet_id_8cb3251a_fk_dealer_wallets_id` FOREIGN KEY (`wallet_id`) REFERENCES `dealer_wallets` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `wallet_transactions` (`id`,`kind`,`amount`,`balance_after`,`reason`,`reference`,`created_at`,`actor_id`,`order_id`,`wallet_id`) VALUES (1,'credit','10000.00','10000.00','Admin top-up','','2026-05-11 05:21:59.015041',6,NULL,1);

DROP TABLE IF EXISTS `warehouses`;
CREATE TABLE `warehouses` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `code` varchar(10) NOT NULL,
  `address` longtext NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `warehouses` (`id`,`name`,`code`,`address`,`is_active`,`created_at`) VALUES (1,'Main Warehouse','MAIN','Bengaluru, IN',1,'2026-05-10 15:58:28.364721');

DROP TABLE IF EXISTS `wishlist_items`;
CREATE TABLE `wishlist_items` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `added_at` datetime(6) NOT NULL,
  `product_id` bigint(20) NOT NULL,
  `user_id` bigint(20) NOT NULL,
  `variant_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `one_wishlist_row_per_user_product_variant` (`user_id`,`product_id`,`variant_id`),
  KEY `wishlist_items_product_id_0509b6b7_fk_products_id` (`product_id`),
  KEY `wishlist_items_variant_id_cc0ba4cb_fk_product_variants_id` (`variant_id`),
  CONSTRAINT `wishlist_items_product_id_0509b6b7_fk_products_id` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`),
  CONSTRAINT `wishlist_items_user_id_fb64a501_fk_users_id` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `wishlist_items_variant_id_cc0ba4cb_fk_product_variants_id` FOREIGN KEY (`variant_id`) REFERENCES `product_variants` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;
INSERT INTO `wishlist_items` (`id`,`added_at`,`product_id`,`user_id`,`variant_id`) VALUES (3,'2026-05-12 15:46:04.370929',6,8,NULL);
INSERT INTO `wishlist_items` (`id`,`added_at`,`product_id`,`user_id`,`variant_id`) VALUES (4,'2026-05-14 10:40:35.963802',17,7,NULL);
INSERT INTO `wishlist_items` (`id`,`added_at`,`product_id`,`user_id`,`variant_id`) VALUES (5,'2026-05-18 08:18:39.196275',15,14,NULL);
INSERT INTO `wishlist_items` (`id`,`added_at`,`product_id`,`user_id`,`variant_id`) VALUES (6,'2026-05-23 13:20:49.804410',16,19,NULL);

SET FOREIGN_KEY_CHECKS=1;
