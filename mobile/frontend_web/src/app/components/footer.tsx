import React from 'react';

const Footer: React.FC = () => {
    return (
        <footer className="bg-gray-800 text-white py-4 text-center">
            <p>&copy; {new Date().getFullYear()} Your Company. All rights reserved.</p>
        </footer>
    );
};

export default Footer;
