ALTER TABLE `vehicles` ADD `business` INT NOT NULL DEFAULT '-1' ;

--
-- Table structure for table `businesses`
--

CREATE TABLE IF NOT EXISTS `businesses` (
`id` int(11) NOT NULL,
  `title` int(11) NOT NULL,
  `bank_card` varchar(100) NOT NULL DEFAULT '0000 0000 0000 0000',
  `created_by` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `business_accounts`
--

CREATE TABLE IF NOT EXISTS `business_accounts` (
`id` int(11) NOT NULL,
  `recipient` varchar(250) NOT NULL,
  `recipient_type` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `description` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `business_members`
--

CREATE TABLE IF NOT EXISTS `business_members` (
`id` int(11) NOT NULL,
  `character` int(11) NOT NULL,
  `business` int(11) NOT NULL,
  `rank` varchar(200) NOT NULL,
  `wage` int(11) NOT NULL,
  `leader` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `business_rentals`
--

CREATE TABLE IF NOT EXISTS `business_rentals` (
`id` int(11) NOT NULL,
  `business` int(11) NOT NULL,
  `rental_id` int(11) NOT NULL,
  `rental_type` int(11) NOT NULL,
  `rental_price` int(11) NOT NULL,
  `rented_to` int(11) NOT NULL,
  `rented_time` int(11) NOT NULL,
  `rented_phone` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `businesses`
--
ALTER TABLE `businesses`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `business_accounts`
--
ALTER TABLE `business_accounts`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `business_members`
--
ALTER TABLE `business_members`
 ADD PRIMARY KEY (`id`);

--
-- Indexes for table `business_rentals`
--
ALTER TABLE `business_rentals`
 ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `businesses`
--
ALTER TABLE `businesses`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `business_accounts`
--
ALTER TABLE `business_accounts`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `business_members`
--
ALTER TABLE `business_members`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `business_rentals`
--
ALTER TABLE `business_rentals`
MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;