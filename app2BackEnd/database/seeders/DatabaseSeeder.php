<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        if (!User::where('email', 'admin123@gmail.com')->exists()) {
            User::create([
                'name' => 'Aziz',
                'email' => 'admin123@gmail.com',
                'password' => Hash::make('admin123'),
            ]);
            
        }


    }
}
