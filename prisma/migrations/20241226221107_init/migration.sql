-- CreateTable
CREATE TABLE "User" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "username" TEXT,
    "passwordHash" TEXT,
    "googleId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Character" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "campaignId" TEXT,
    "origin" TEXT NOT NULL,
    "tier" INTEGER NOT NULL DEFAULT 1,
    "hunt" INTEGER NOT NULL DEFAULT 0,
    "study" INTEGER NOT NULL DEFAULT 0,
    "survey" INTEGER NOT NULL DEFAULT 0,
    "tinker" INTEGER NOT NULL DEFAULT 0,
    "finesse" INTEGER NOT NULL DEFAULT 0,
    "prowl" INTEGER NOT NULL DEFAULT 0,
    "skirmish" INTEGER NOT NULL DEFAULT 0,
    "wreck" INTEGER NOT NULL DEFAULT 0,
    "bizarre" INTEGER NOT NULL DEFAULT 0,
    "command" INTEGER NOT NULL DEFAULT 0,
    "consort" INTEGER NOT NULL DEFAULT 0,
    "sway" INTEGER NOT NULL DEFAULT 0,
    "stress" INTEGER NOT NULL DEFAULT 0,
    "maxStress" INTEGER NOT NULL DEFAULT 9,
    "trauma" INTEGER NOT NULL DEFAULT 0,
    "traumaConditions" TEXT[],
    "vice" TEXT NOT NULL,
    "vicePurveyor" TEXT NOT NULL,
    "friends" TEXT[],
    "rivals" TEXT[],
    "insightXp" INTEGER NOT NULL DEFAULT 0,
    "prowessXp" INTEGER NOT NULL DEFAULT 0,
    "resolveXp" INTEGER NOT NULL DEFAULT 0,
    "playbackXp" INTEGER NOT NULL DEFAULT 0,
    "harm" JSONB NOT NULL DEFAULT '{"level1": [], "level2": [], "level3": [], "level4": false}',
    "specialArmor" INTEGER NOT NULL DEFAULT 2,
    "items" TEXT[],
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Character_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Stand" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "form" TEXT NOT NULL,
    "consciousness" TEXT NOT NULL,
    "power" TEXT NOT NULL,
    "speed" TEXT NOT NULL,
    "range" TEXT NOT NULL,
    "durability" TEXT NOT NULL,
    "precision" TEXT NOT NULL,
    "potential" TEXT NOT NULL,
    "appearance" TEXT NOT NULL,
    "manifestation" TEXT,
    "specialTraits" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Stand_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "StandAbility" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "standId" TEXT NOT NULL,
    "isUnique" BOOLEAN NOT NULL DEFAULT true,
    "offenseUse" TEXT,
    "defenseUse" TEXT,
    "utilityUse" TEXT,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "StandAbility_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Campaign" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "dmId" TEXT NOT NULL,
    "tier" INTEGER NOT NULL DEFAULT 1,
    "status" TEXT NOT NULL DEFAULT 'ACTIVE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Campaign_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Clock" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "segments" INTEGER NOT NULL DEFAULT 4,
    "filled" INTEGER NOT NULL DEFAULT 0,
    "campaignId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Clock_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Roll" (
    "id" TEXT NOT NULL,
    "characterId" TEXT NOT NULL,
    "campaignId" TEXT NOT NULL,
    "rollType" TEXT NOT NULL,
    "actionType" TEXT,
    "position" TEXT NOT NULL,
    "effect" TEXT NOT NULL,
    "dice" INTEGER NOT NULL,
    "results" INTEGER[],
    "outcome" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Roll_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_CampaignPlayers" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");

-- CreateIndex
CREATE UNIQUE INDEX "User_username_key" ON "User"("username");

-- CreateIndex
CREATE UNIQUE INDEX "User_googleId_key" ON "User"("googleId");

-- CreateIndex
CREATE UNIQUE INDEX "Stand_characterId_key" ON "Stand"("characterId");

-- CreateIndex
CREATE UNIQUE INDEX "_CampaignPlayers_AB_unique" ON "_CampaignPlayers"("A", "B");

-- CreateIndex
CREATE INDEX "_CampaignPlayers_B_index" ON "_CampaignPlayers"("B");

-- AddForeignKey
ALTER TABLE "Character" ADD CONSTRAINT "Character_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Character" ADD CONSTRAINT "Character_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Stand" ADD CONSTRAINT "Stand_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "Character"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "StandAbility" ADD CONSTRAINT "StandAbility_standId_fkey" FOREIGN KEY ("standId") REFERENCES "Stand"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Campaign" ADD CONSTRAINT "Campaign_dmId_fkey" FOREIGN KEY ("dmId") REFERENCES "User"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Clock" ADD CONSTRAINT "Clock_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roll" ADD CONSTRAINT "Roll_characterId_fkey" FOREIGN KEY ("characterId") REFERENCES "Character"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Roll" ADD CONSTRAINT "Roll_campaignId_fkey" FOREIGN KEY ("campaignId") REFERENCES "Campaign"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_CampaignPlayers" ADD CONSTRAINT "_CampaignPlayers_A_fkey" FOREIGN KEY ("A") REFERENCES "Campaign"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_CampaignPlayers" ADD CONSTRAINT "_CampaignPlayers_B_fkey" FOREIGN KEY ("B") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
