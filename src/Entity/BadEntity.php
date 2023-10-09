<?php

namespace App\Entity;

use ApiPlatform\Metadata\ApiResource;
use ApiPlatform\Metadata\Get;
use ApiPlatform\Metadata\GetCollection;
use ApiPlatform\Metadata\Link;
use ApiPlatform\Metadata\Post;
use ApiPlatform\Metadata\Put;
use App\State\ExceptionThrowingStateProcessor;
use App\State\ExceptionThrowingStateProvider;
use Doctrine\ORM\Mapping as ORM;

#[ORM\Entity]
#[ApiResource(
    shortName: 'BadEntity',
    operations: [
        new GetCollection(
            uriTemplate: '/bad_entity.{_format}',
            itemUriTemplate: '/bad_entity/{id}.{_format}',
        ),
        new Get(
            uriTemplate: '/bad_entity/{id}.{_format}',
            uriVariables: ['id' => new Link(fromClass: self::class, identifiers: ['id'], compositeIdentifier: false)],
            requirements: ['id' => '^[0-9]*$'],
        ),
        new Post(
            uriTemplate: '/bad_entity.{_format}',
        ),
        new Put(
            uriTemplate: '/bad_entity/{id}.{_format}',
            uriVariables: ['id' => new Link(fromClass: self::class, identifiers: ['id'], compositeIdentifier: false)],
            requirements: ['id' => '^[0-9]*$'],
        ),
    ],
    provider: ExceptionThrowingStateProvider::class,
    processor: ExceptionThrowingStateProcessor::class
)]
class BadEntity
{
    #[ORM\Id]
    #[ORM\GeneratedValue]
    #[ORM\Column]
    private ?int $id = null; // Returns value from numberId on the API

    #[ORM\Column(length: 127)]
    private ?string $description = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function setId(int $id): static
    {
        $this->id = $id;

        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(string $description): static
    {
        $this->description = $description;

        return $this;
    }
}
