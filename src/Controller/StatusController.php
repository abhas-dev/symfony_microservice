<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Attribute\Route;

class StatusController
{
    #[Route('/health', name: 'health_check')]
    public function healthCheck(): JsonResponse
    {
        return new JsonResponse([
            'app' => 'true',
        ]);
    }
}
